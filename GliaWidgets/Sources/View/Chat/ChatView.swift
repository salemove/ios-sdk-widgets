import UIKit

extension ChatView {
    struct Props {
        let header: Header.Props
    }
}

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
    var selectCustomCardOption: ((HtmlMetadata.Option, MessageRenderer.Message.Identifier) -> Void)?

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

    private let messageRenderer: MessageRenderer?
    private let environment: Environment

    private var heightCache: [String: CGFloat] = [:]

    var props: Props {
        didSet {
            renderHeaderProps()
        }
    }

    init(
        with style: ChatStyle,
        messageRenderer: MessageRenderer?,
        environment: Environment,
        props: Props
    ) {
        self.style = style
        self.messageRenderer = messageRenderer
        self.environment = environment
        self.messageEntryView = ChatMessageEntryView(
            with: style.messageEntry,
            environment: .init(
                gcd: environment.gcd,
                uiApplication: environment.uiApplication
            )
        )
        self.unreadMessageIndicatorView = UnreadMessageIndicatorView(
            with: style.unreadMessageIndicator,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )

        self.typingIndicatorView = OperatorTypingIndicatorView(
            style: style.operatorTypingIndicator,
            accessibilityProperties: .init(operatorName: style.accessibility.operator)
        )
        self.props = props
        super.init(
            with: style,
            layout: .chat,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication
            ),
            headerProps: props.header
        )
        self.accessibilityIdentifier = "chat_root_view"
        defineLayout()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        moveCallBubbleVisible()
    }

    override func setup() {
        super.setup()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = kChatTableViewInsets
        tableView.register(cell: ChatItemCell.self)

        unreadMessageIndicatorView.tapped = { [weak self] in
            self?.scrollToBottom(animated: true)
        }

        tableAndIndicatorStack.axis = .vertical

        observeKeyboard()
        addKeyboardDismissalTapGesture()
        typingIndicatorView.accessibilityIdentifier = "chat_typingIndicator"
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
                    case .operatorMessage(let message, let showsImage, let imageUrl):
                        // forward operator name to typing indicator's accessibility
                        if let operatorName = message.operator?.name {
                            typingIndicatorView.accessibilityProperties.operatorName = operatorName
                        }

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
        guard
            let rows = numberOfRows?(section),
            rows >= count
        else { return }
        // Here we ignore `animated` in case there are no
        // visible cells. Without this workaround there
        // could be a crash related to `UITableView.performBatchUpdates`
        // method.
        if animated, !tableView.visibleCells.isEmpty {
            tableView.performBatchUpdates {
                let indexPaths = (rows - count ..< rows)
                    .map { IndexPath(row: $0, section: section) }
                tableView.insertRows(at: indexPaths, with: .fade)
            }
        } else {
            refreshAll()
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

    override func defineLayout() {
        super.defineLayout()
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(
            with: .zero,
            excludingEdge: .bottom
        )

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

    func renderHeaderProps() {
        header.props = props.header
    }
}

extension ChatView {
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
            let view = VisitorChatMessageView(
                with: style.visitorMessage
            )
            view.appendContent(
                .text(
                    message.content,
                    accessibility: Self.visitorAccessibilityOutgoingMessage(
                        for: message,
                        visitor: style.accessibility.visitor,
                        isFontScalingEnabled: style.accessibility.isFontScalingEnabled
                    )
                ),
                animated: false
            )
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
            let view = VisitorChatMessageView(
                with: style.visitorMessage
            )
            view.appendContent(
                .text(
                    message.content,
                    accessibility: Self.visitorAccessibilityMessage(
                        for: message,
                        visitor: style.accessibility.visitor,
                        isFontScalingEnabled: style.accessibility.isFontScalingEnabled
                    )
                ),
                animated: false
            )
            view.appendContent(
                .downloads(
                    message.downloads,
                    accessibility: .init(from: .visitor)
                ),
                animated: false
            )
            view.downloadTapped = { [weak self] in self?.downloadTapped?($0) }
            view.linkTapped = { [weak self] in self?.linkTapped?($0) }
            view.status = status
            return .visitorMessage(view)
        case .operatorMessage(let message, let showsImage, let imageUrl):
            return operatorMessageContent(
                message,
                showsImage: showsImage,
                imageUrl: imageUrl
            )
        case .choiceCard(let message, let showsImage, let imageUrl, let isActive):
            return choiceCardMessageContent(
                message,
                showsImage: showsImage,
                imageUrl: imageUrl,
                isActive: isActive
            )
        case .customCard(let chatMessage, let showsImage, let imageUrl, let isActive):
            let message = MessageRenderer.Message(chatMessage: chatMessage)
            // Response card should be shown by default even if option is selected.
            let shouldShow = messageRenderer?.shouldShowCard(message) ?? true
            // Response card is considered as noninteractable by default.
            let isInteractable = messageRenderer?.isInteractable(message) ?? false
            // Need to hide interactable response card if integrator returns `false`
            // via shouldShowCard interface.
            if !shouldShow, isInteractable {
                return .none
            }

            guard let contentView = messageRenderer?.render(message) else {
                if chatMessage.isChoiceCard {
                    return choiceCardMessageContent(
                        chatMessage,
                        showsImage: showsImage,
                        imageUrl: imageUrl,
                        isActive: isActive
                    )
                }
                return operatorMessageContent(
                    chatMessage,
                    showsImage: showsImage,
                    imageUrl: imageUrl
                )
            }

            let container = CustomCardContainerView()
            if let webCardView = contentView as? WebMessageCardView {
                webCardView.isUserInteractionEnabled = isActive
                webCardView.delegate = self
                webCardView.updateHeight(heightCache[chatMessage.id] ?? 0)
                container.willDisplayView = webCardView.startLoading
            }

            container.addContentView(contentView)
            return .customCard(container)
        case .callUpgrade(let kind, let duration):
            let callStyle = callUpgradeStyle(for: kind.value)
            let view = ChatCallUpgradeView(
                with: callStyle,
                duration: duration
            )
            kind.addObserver(self) { [weak self] kind, _ in
                guard let self = self else { return }

                view.style = self.callUpgradeStyle(for: kind)
                self.refreshAll()
            }
            return .callUpgrade(view)
        case .operatorConnected(let name, let imageUrl):
            let connectView = ConnectView(
                with: style.connect,
                layout: .chat,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding)
            )
            connectView.setState(
                .connected(name: name, imageUrl: imageUrl),
                animated: false
            )
            return .queueOperator(connectView)
        case .transferring:
            let connectView = ConnectView(
                with: style.connect,
                layout: .chat,
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding)
            )
            connectView.setState(
                .transferring,
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

    private func operatorMessageContent(
        _ message: ChatMessage,
        showsImage: Bool,
        imageUrl: String?
    ) -> ChatItemCell.Content {
        let view = OperatorChatMessageView(
            with: style.operatorMessage,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
        view.appendContent(
            .text(
                message.content,
                accessibility: Self.operatorAccessibilityMessage(
                    for: message,
                    operator: style.accessibility.operator,
                    isFontScalingEnabled: style.accessibility.isFontScalingEnabled
                )
            ),
            animated: false
        )
        view.appendContent(
            .downloads(
                message.downloads,
                accessibility: .init(from: .operator(message.operator?.name ?? style.accessibility.operator))),
            animated: false
        )
        view.downloadTapped = { [weak self] in self?.downloadTapped?($0) }
        view.linkTapped = { [weak self] in self?.linkTapped?($0) }
        view.showsOperatorImage = showsImage
        view.setOperatorImage(fromUrl: imageUrl, animated: false)
        return .operatorMessage(view)
    }

    private func choiceCardMessageContent(
        _ message: ChatMessage,
        showsImage: Bool,
        imageUrl: String?,
        isActive: Bool
    ) -> ChatItemCell.Content {
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
    }
}

// MARK: WebMessageCardViewDelegate

extension ChatView: WebMessageCardViewDelegate {
    func viewDidUpdateHeight(
        _ view: WebMessageCardView,
        height: CGFloat,
        for messageId: MessageRenderer.Message.Identifier
    ) {
        if let cachedHeight = heightCache[messageId.rawValue],
            cachedHeight == height {
            return
        }
        heightCache[messageId.rawValue] = height
        updateTableView(animated: true)

        guard isLastMessage(messageId) else { return }
        scrollToBottom(animated: true)
    }

    func didSelectCustomCardOption(
        _ view: WebMessageCardView,
        selectedOption: HtmlMetadata.Option,
        for messageId: MessageRenderer.Message.Identifier
    ) {
        selectCustomCardOption?(selectedOption, messageId)
    }

    func didCallMobileAction(_ view: WebMessageCardView, action: String) {
        messageRenderer?.callMobileActionHandler(action)
    }

    func didSelectURL(_ view: WebMessageCardView, url: URL) {
        linkTapped?(url)
    }

    private func isLastMessage(_ messageId: MessageRenderer.Message.Identifier) -> Bool {
        let numberOfSections = { self.numberOfSections?() ?? 0 }
        let numberOfRows = { section in self.numberOfRows?(section) ?? 0 }
        let sections = (0 ..< numberOfSections()).reversed()

        guard let section = sections.first(where: { numberOfRows($0) > 0 }) else { return false }
        let lastRowIndex = numberOfRows(section) - 1

        guard
            let lastItem = itemForRow?(lastRowIndex, section),
            case .customCard(let message, _, _, _) = lastItem.kind
        else { return false }

        return message.id == messageId.rawValue
    }
}

// MARK: Call Bubble

extension ChatView {
    func setCallBubbleImage(with imageUrl: String?) {
        guard let callBubble = callBubble else { return }

        callBubble.kind = .userImage(url: imageUrl)
    }

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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let cell = cell as? ChatItemCell,
            case .customCard(let view) = cell.content
        else { return }
        view.willDisplayView?()
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = itemForRow?(indexPath.row, indexPath.section) else { return CGFloat.zero }
        guard case .none = content(for: item) else { return UITableView.automaticDimension }
        return CGFloat.zero
    }
}

// MARK: - Accessibility
extension ChatView {
    static func operatorAccessibilityMessage(
        for chatMessage: ChatMessage,
        `operator`: String,
        isFontScalingEnabled: Bool
    ) -> ChatMessageContent.TextAccessibilityProperties {
        .init(
            label: chatMessage.operator?.name ?? `operator`,
            value: chatMessage.content,
            isFontScalingEnabled: isFontScalingEnabled
        )
    }

    static func visitorAccessibilityMessage(
        for chatMessage: ChatMessage,
        visitor: String,
        isFontScalingEnabled: Bool
    ) -> ChatMessageContent.TextAccessibilityProperties {
        .init(
            label: visitor,
            value: chatMessage.content,
            isFontScalingEnabled: isFontScalingEnabled
        )
    }

    static func visitorAccessibilityOutgoingMessage(
        for outgoingMessage: OutgoingMessage,
        visitor: String,
        isFontScalingEnabled: Bool
    ) -> ChatMessageContent.TextAccessibilityProperties {
        .init(
            label: visitor,
            value: outgoingMessage.content,
            isFontScalingEnabled: isFontScalingEnabled
        )
    }
}
