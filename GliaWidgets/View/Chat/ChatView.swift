import UIKit

class ChatView: EngagementView {
    let tableAndIndicatorStack = UIStackView()
    let tableView = UITableView()
    let messageEntryView: ChatMessageEntryView
    let unreadMessageIndicatorView: UnreadMessageIndicatorView
    let typingIndicatorView: OperatorTypingIndicatorView
    var numberOfSections: (() -> Int?)?
    var numberOfRows: ((Int) -> Int?)?
    var itemForRow: ((Int, Int) -> ChatItem?)?
    var fileTapped: ((LocalFile) -> Void)?
    var downloadTapped: ((FileDownload) -> Void)?
    var callBubbleTapped: (() -> Void)?
    var choiceOptionSelected: ((ChatChoiceCardOption, String) -> Void)!
    var chatScrolledToBottom: ((Bool) -> Void)?
    var linkTapped: ((URL) -> Void)?

    private let style: ChatStyle
    private var messageEntryViewBottomConstraint: NSLayoutConstraint!
    private var callBubble: BubbleView?
    private let keyboardObserver = KeyboardObserver()

    private let kUnreadMessageIndicatorInset: CGFloat = -3
    private let kCallBubbleEdgeInset: CGFloat = 10
    private let kCallBubbleSize = CGSize(width: 60, height: 60)
    private let kChatTableViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    private let kOperatorTypingIndicatorViewSize = CGSize(width: 28, height: 28)
    private var callBubbleBounds: CGRect {
        let x = safeAreaInsets.left + kCallBubbleEdgeInset
        let y = safeAreaInsets.top + kCallBubbleEdgeInset
        let width = frame.width - safeAreaInsets.left - safeAreaInsets.right - 2 * kCallBubbleEdgeInset
        let height = messageEntryView.frame.maxY - safeAreaInsets.top - 2 * kCallBubbleEdgeInset

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private let environment: Environment

    init(
        with style: ChatStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        self.messageEntryView = ChatMessageEntryView(with: style.messageEntry)
        self.unreadMessageIndicatorView = UnreadMessageIndicatorView(
            with: style.unreadMessageIndicator,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )

        #warning("Find way how to provide operator name")
        self.typingIndicatorView = OperatorTypingIndicatorView(
            style: style.operatorTypingIndicator,
            accessibilityProperties: .init(operatorName: "Operator")
        )
        super.init(
            with: style,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding
            )
        )
        setup()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        moveCallBubbleVisible()
    }

    override func setup() {
        super.setup()
        header.title = style.title

        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = kChatTableViewInsets
        tableView.register(cell: ChatItemCell.self)

        unreadMessageIndicatorView.tapped = { [weak self] in
            self?.scrollToBottom(animated: true)
        }

        tableAndIndicatorStack.axis = .vertical

        observeKeyboard()
        addKeyboardDismissalTapGesture()
        typingIndicatorView.isHidden = true
    }

    func setOperatorTypingIndicatorIsHidden(to isHidden: Bool) {
        typingIndicatorView.isHidden = isHidden
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
        updateTableView(animated: animated)
    }

    func updateItemsUserImage(animated: Bool) {
        tableView.indexPathsForVisibleRows?.forEach {
            if let cell = tableView.cellForRow(at: $0) as? ChatItemCell,
               let item = itemForRow?($0.row, $0.section) {
                switch cell.content {
                case .operatorMessage(let view):
                    switch item.kind {
                    case .operatorMessage(_, let showsImage, let imageUrl):
                        view.showsOperatorImage = showsImage
                        view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                    default:
                        break
                    }
                case .choiceCard(let view):
                    switch item.kind {
                    case .choiceCard(_, let showsImage, let imageUrl, _):
                        view.showsOperatorImage = showsImage
                        view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
    }

    func appendRows(_ count: Int, to section: Int, animated: Bool) {
        guard let rows = numberOfRows?(section) else { return }

        if animated {
            let indexPaths = (rows - count ..< rows)
                .map { IndexPath(row: $0, section: section) }
            tableView.insertRows(at: indexPaths, with: .bottom)
        } else {
            tableView.reloadData()
        }
    }

    func scrollToBottom(animated: Bool) {
        tableView.scrollToBottom(animated: animated)
    }

    func refreshRow(_ row: Int, in section: Int, animated: Bool) {
        let indexPath = IndexPath(row: row, section: section)

        guard
            tableView.indexPathsForVisibleRows?.contains(indexPath) == true,
            let cell = tableView.cellForRow(at: indexPath) as? ChatItemCell,
            let item = itemForRow?(indexPath.row, indexPath.section)
        else { return }

        cell.content = content(for: item)
        tableView.reloadRows(at: [indexPath], with: animated ? .fade : .none)
    }

    func refreshRows(_ rows: [Int], in section: Int, animated: Bool) {
        let refreshBlock = {
            self.tableView.beginUpdates()
            for row in rows {
                self.refreshRow(row, in: section, animated: animated)
            }
            self.tableView.endUpdates()
        }

        if animated {
            refreshBlock()
        } else {
            UIView.performWithoutAnimation {
                refreshBlock()
            }
        }
    }

    func refreshSection(_ section: Int) {
        UIView.performWithoutAnimation {
            tableView.reloadSections([section], with: .none)
        }
    }

    func refreshAll() {
        tableView.reloadData()
    }
}

extension ChatView {
    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(
            with: .zero,
            excludingEdge: .bottom
        )

        typingIndicatorView.autoSetDimensions(to: kOperatorTypingIndicatorViewSize)

        tableAndIndicatorStack.addArrangedSubviews([tableView, typingIndicatorView])
        addSubview(tableAndIndicatorStack)
        tableAndIndicatorStack.autoPinEdge(.top, to: .bottom, of: header)
        tableAndIndicatorStack.autoPinEdge(toSuperviewSafeArea: .left)
        tableAndIndicatorStack.autoPinEdge(toSuperviewSafeArea: .right)

        addSubview(messageEntryView)
        messageEntryViewBottomConstraint = messageEntryView.autoPinEdge(
            toSuperviewSafeArea: .bottom
        )
        messageEntryView.autoPinEdge(toSuperviewSafeArea: .left)
        messageEntryView.autoPinEdge(toSuperviewSafeArea: .right)
        messageEntryView.autoPinEdge(.top, to: .bottom, of: tableAndIndicatorStack)

        addSubview(unreadMessageIndicatorView)
        unreadMessageIndicatorView.autoAlignAxis(toSuperviewAxis: .vertical)
        unreadMessageIndicatorView.autoPinEdge(
            .bottom,
            to: .top,
            of: messageEntryView,
            withOffset: kUnreadMessageIndicatorInset
        )
    }

    private func addKeyboardDismissalTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false

        tableView.addGestureRecognizer(tapGesture)
    }

    @objc
    private func dismissKeyboard(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            endEditing(true)
        }
    }

    // swiftlint:disable function_body_length
    private func content(for item: ChatItem) -> ChatItemCell.Content {
        switch item.kind {
        case .queueOperator:
            return .queueOperator(connectView)
        case .outgoingMessage(let message):
            let view = VisitorChatMessageView(with: style.visitorMessage)
            view.appendContent(.text(message.content, accessibility: Self.visitorAccessibilityOutgoingMessage(for: message)), animated: false)
            view.appendContent(
                .files(
                    message.files,
                    accessibility: .init(from: .visitor)
                ),
                animated: false
            )
            view.fileTapped = { [weak self] in self?.fileTapped?($0) }
            view.linkTapped = { [weak self] in self?.linkTapped?($0) }
            return .outgoingMessage(view)
        case .visitorMessage(let message, let status):
            let view = VisitorChatMessageView(with: style.visitorMessage)
            view.appendContent(.text(message.content, accessibility: Self.visitorAccessibilityMessage(for: message)), animated: false)
            view.appendContent(.downloads(message.downloads,
                                          accessibility: .init(from: .visitor)), animated: false)
            view.downloadTapped = { [weak self] in self?.downloadTapped?($0) }
            view.linkTapped = { [weak self] in self?.linkTapped?($0) }
            view.status = status
            return .visitorMessage(view)
        case .operatorMessage(let message, let showsImage, let imageUrl):
            let view = OperatorChatMessageView(
                with: style.operatorMessage,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache
                )
            )
            view.appendContent(.text(message.content, accessibility: Self.operatorAccessibilityMessage(for: message)), animated: false)
            #warning("Provide proper localized 'Operator'")
            view.appendContent(
                .downloads(
                    message.downloads,

                    accessibility: .init(from: .operator(message.operator?.name ?? "Operator"))),
                animated: false
            )
            view.downloadTapped = { [weak self] in self?.downloadTapped?($0) }
            view.linkTapped = { [weak self] in self?.linkTapped?($0) }
            view.showsOperatorImage = showsImage
            view.setOperatorImage(fromUrl: imageUrl, animated: false)
            return .operatorMessage(view)
        case .choiceCard(let message, let showsImage, let imageUrl, let isActive):
            let view = ChoiceCardView(
                with: style.choiceCard,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache
                )
            )
            let choiceCard = ChoiceCard(with: message, isActive: isActive)
            view.showsOperatorImage = showsImage
            view.setOperatorImage(fromUrl: imageUrl, animated: false)
            view.onOptionTapped = { self.choiceOptionSelected($0, message.id) }
            view.appendContent(.choiceCard(choiceCard), animated: false)
            return .choiceCard(view)
        case .callUpgrade(let kind, let duration):
            let callStyle = callUpgradeStyle(for: kind.value)
            let view = ChatCallUpgradeView(
                with: callStyle,
                duration: duration
            )
            kind.addObserver(self) { kind, _ in
                view.style = self.callUpgradeStyle(for: kind)
            }
            return .callUpgrade(view)
        case .operatorConnected(let name, let imageUrl):
            let connectView = ConnectView(
                with: style.connect,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding)
            )
            connectView.operatorView.isHidden = imageUrl == nil
            connectView.setState(
                .connected(name: name, imageUrl: imageUrl),
                animated: false
            )
            return .queueOperator(connectView)
        }
    }
    // swiftlint:enable function_body_length

    private func callUpgradeStyle(for callKind: CallKind) -> ChatCallUpgradeStyle {
        return callKind == .audio
            ? style.audioUpgrade
            : style.videoUpgrade
    }

    private func updateTableView(animated: Bool) {
        if animated {
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    private func isBottomReached(for scrollView: UIScrollView) -> Bool {
        let chatBottomOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let currentPositionOffset = scrollView.contentOffset.y + scrollView.contentInset.top

        return currentPositionOffset >= chatBottomOffset
    }
}

// MARK: Call Bubble

extension ChatView {
    func showCallBubble(with imageUrl: String?, animated: Bool) {
        guard callBubble == nil else { return }
        let callBubble = BubbleView(
            with: style.callBubble,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
        callBubble.kind = .userImage(url: imageUrl)
        callBubble.tap = { [weak self] in self?.callBubbleTapped?() }
        callBubble.pan = { [weak self] in self?.moveCallBubble($0, animated: true) }
        callBubble.frame = CGRect(
            origin: CGPoint(
                x: callBubbleBounds.maxX - kCallBubbleSize.width,
                y: callBubbleBounds.maxY - kCallBubbleSize.height
            ),
            size: kCallBubbleSize
        )
        self.callBubble = callBubble

        addSubview(callBubble)
    }

    private func moveCallBubble(_ translation: CGPoint, animated: Bool) {
        guard let callBubble = callBubble else { return }

        var frame = callBubble.frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y

        if callBubbleBounds.contains(frame) {
            callBubble.frame = frame
        }
    }

    private func moveCallBubbleVisible() {
        guard let callBubble = callBubble else { return }
        bringSubviewToFront(callBubble)

        var frame: CGRect = callBubble.frame

        if callBubble.frame.minX < callBubbleBounds.minX {
            frame.origin.x = callBubbleBounds.minX
        }
        if callBubble.frame.minY < callBubbleBounds.minY {
            frame.origin.y = callBubbleBounds.minY
        }
        if callBubble.frame.maxX > callBubbleBounds.maxX {
            frame.origin.x = callBubbleBounds.maxX - callBubble.frame.width
        }
        if callBubble.frame.maxY > callBubbleBounds.maxY {
            frame.origin.y = callBubbleBounds.maxY - callBubble.frame.height
        }

        callBubble.frame = frame
    }
}

// MARK: Keyboard

extension ChatView {
    private func observeKeyboard() {
        keyboardObserver.keyboardWillShow = { [unowned self] properties in
            let bottomInset = safeAreaInsets.bottom
            let newEntryConstraint = -properties.finalFrame.height + bottomInset
            UIView.animate(
                withDuration: properties.duration,
                delay: 0.0,
                options: properties.animationOptions,
                animations: { [weak self] in
                    self?.messageEntryViewBottomConstraint.constant = newEntryConstraint
                    self?.layoutIfNeeded()
                },
                completion: { [weak self] _ in
                    self?.tableView.scrollToBottom(animated: true)
                }
            )
        }

        keyboardObserver.keyboardWillHide = { [unowned self] properties in
            UIView.animate(
                withDuration: properties.duration,
                delay: 0.0,
                options: properties.animationOptions,
                animations: { [weak self] in
                    self?.messageEntryViewBottomConstraint.constant = 0
                    self?.layoutIfNeeded()
                }
            )
        }
    }
}

// MARK: UITableViewDataSource

extension ChatView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections?() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows?(section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let item = itemForRow?(indexPath.row, indexPath.section),
            let cell: ChatItemCell = tableView.dequeue(cellFor: indexPath)
        else { return UITableViewCell() }
        cell.content = content(for: item)
        return cell
    }
}

// MARK: UITableViewDelegate

extension ChatView: UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing(true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        chatScrolledToBottom?(isBottomReached(for: scrollView))
    }
}

// MARK: - Accessibility
extension ChatView {
    static func operatorAccessibilityMessage(for chatMessage: ChatMessage) -> ChatMessageContent.TextAccessibilityProperties {
        .init(label: chatMessage.operator?.name ?? "Operator", value: chatMessage.content)
    }

    static func visitorAccessibilityMessage(for chatMessage: ChatMessage) -> ChatMessageContent.TextAccessibilityProperties {
        .init(label: "You", value: chatMessage.content)
    }

    static func visitorAccessibilityOutgoingMessage(for outgoingMessage: OutgoingMessage) -> ChatMessageContent.TextAccessibilityProperties {
        .init(label: "You", value: outgoingMessage.content)
    }

    struct AccessibilityProperties {
        let operatorName: String
    }
}
