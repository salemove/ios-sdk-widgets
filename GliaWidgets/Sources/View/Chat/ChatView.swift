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
    let typingIndicatorContainer = UIView()
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
    var gvaButtonTapped: ((GvaOption) -> Void)?

    let style: ChatStyle
    let environment: Environment

    private lazy var quickReplyView = QuickReplyView(
        style: style.gliaVirtualAssistant.quickReplyButton
    )
    private var messageEntryViewBottomConstraint: NSLayoutConstraint!
    private var callBubble: BubbleView?
    private let keyboardObserver = KeyboardObserver()
    private let kUnreadMessageIndicatorInset: CGFloat = -3
    private let kCallBubbleEdgeInset: CGFloat = 10
    private let kCallBubbleSize = CGSize(width: 60, height: 60)
    private let kChatTableViewInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    private var callBubbleBounds: CGRect {
        let x = safeAreaInsets.left + kCallBubbleEdgeInset
        let y = safeAreaInsets.top + kCallBubbleEdgeInset
        let width = frame.width - safeAreaInsets.left - safeAreaInsets.right - 2 * kCallBubbleEdgeInset
        let height = messageEntryView.frame.maxY - safeAreaInsets.top - 2 * kCallBubbleEdgeInset

        return CGRect(x: x, y: y, width: width, height: height)
    }
    private let messageRenderer: MessageRenderer?
    private var heightCache: [String: CGFloat] = [:]

    var props: Props {
        didSet { renderHeaderProps() }
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
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen
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
            accessibilityProperties: .init(operatorName: style.accessibility.operator),
            style: style.operatorTypingIndicator
        )
        typingIndicatorContainer.isAccessibilityElement = true
        typingIndicatorContainer.accessibilityLabel =
        style.operatorTypingIndicator.accessibility.label.withOperatorName(
            OperatorTypingIndicatorView.AccessibilityProperties(operatorName: style.accessibility.operator).operatorName
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
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen
            ),
            headerProps: props.header
        )
        self.accessibilityIdentifier = "chat_root_view"
        defineLayout()
    }

    required init() { fatalError("init() has not been implemented") }

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
        typingIndicatorContainer.isHidden = true
    }

    override func defineLayout() {
        super.defineLayout()
        addSubview(header)
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += header.layoutInSuperview(edges: .horizontal)
        constraints += header.layoutInSuperview(edges: .top)

        typingIndicatorContainer.addSubview(typingIndicatorView)
        typingIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        tableAndIndicatorStack.addArrangedSubviews([tableView, typingIndicatorContainer])
        addSubview(tableAndIndicatorStack)
        tableAndIndicatorStack.translatesAutoresizingMaskIntoConstraints = false
        constraints += tableAndIndicatorStack.topAnchor.constraint(equalTo: header.bottomAnchor)
        constraints += tableAndIndicatorStack.layoutInSuperview(edges: .horizontal)

        constraints += [
            typingIndicatorView.leadingAnchor.constraint(equalTo: typingIndicatorContainer.leadingAnchor, constant: 10),
            typingIndicatorView.topAnchor.constraint(equalTo: typingIndicatorContainer.topAnchor, constant: 10),
            typingIndicatorView.bottomAnchor.constraint(equalTo: typingIndicatorContainer.bottomAnchor),
            typingIndicatorView.widthAnchor.constraint(equalToConstant: 28),
            typingIndicatorView.heightAnchor.constraint(equalToConstant: 14)
        ]

        NSLayoutConstraint.activate([
            typingIndicatorView.leadingAnchor.constraint(equalTo: typingIndicatorContainer.leadingAnchor, constant: 10),
            typingIndicatorView.topAnchor.constraint(equalTo: typingIndicatorContainer.topAnchor, constant: 10),
            typingIndicatorView.bottomAnchor.constraint(equalTo: typingIndicatorContainer.bottomAnchor, constant: -8),
            typingIndicatorView.widthAnchor.constraint(equalToConstant: 28),
            typingIndicatorView.heightAnchor.constraint(equalToConstant: 10)
        ])

        addSubview(quickReplyView)
        constraints += quickReplyView.layoutIn(safeAreaLayoutGuide, edges: .horizontal)
        constraints += quickReplyView.topAnchor.constraint(equalTo: tableAndIndicatorStack.bottomAnchor)

        addSubview(messageEntryView)
        let messageEntryInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 4.5,
            right: 0
        )
        messageEntryViewBottomConstraint = messageEntryView.layoutIn(
            safeAreaLayoutGuide,
            edges: .bottom,
            insets: messageEntryInsets
        ).first
        constraints += messageEntryViewBottomConstraint

        constraints += messageEntryView.layoutIn(safeAreaLayoutGuide, edges: .horizontal)
        constraints += messageEntryView.topAnchor.constraint(equalTo: quickReplyView.bottomAnchor)

        addSubview(unreadMessageIndicatorView)
        unreadMessageIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        constraints += unreadMessageIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)

        constraints += unreadMessageIndicatorView.bottomAnchor.constraint(
            equalTo: messageEntryView.topAnchor, constant: kUnreadMessageIndicatorInset
        )
    }
}

extension ChatView {
    func setOperatorTypingIndicatorIsHidden(to isHidden: Bool) {
        typingIndicatorContainer.isHidden = isHidden
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

                case let .gvaGallery(view, _):
                    switch item.kind {
                    case let .gvaGallery(_, _, showsImage, imageUrl):
                        view.showsOperatorImage = showsImage
                        view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                    default: break
                    }
                default:
                    break
                }
            }
        }
    }

    func appendRows(_ count: Int, to section: Int, animated: Bool) {
        guard let rows = numberOfRows?(section), rows >= count else { return }
        // Here we ignore `animated` in case there are no
        // visible cells. Without this workaround there
        // could be a crash related to `UITableView.performBatchUpdates`
        // method.
        if animated, !tableView.visibleCells.isEmpty {
            let indexPaths = (rows - count ..< rows)
                .map { IndexPath(row: $0, section: section) }

            // In case nothing (empty array) gets inserted, we early-out,
            // otherwise crash will occur for `tableView.insertRows` or
            // `tableView.performBatchUpdates`.
            guard !indexPaths.isEmpty else { return }

            // `tableView.performBatchUpdates` crashes in case if tableView
            // size is .zero. That is why we perform `tableView.insertRows` without
            // `tableView.performBatchUpdates` wrapping.
            if tableView.frame.size == .zero {
                tableView.insertRows(at: indexPaths, with: .fade)
            } else {
                tableView.performBatchUpdates {
                    tableView.insertRows(at: indexPaths, with: .fade)
                }
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

    func refreshSection(
        _ section: Int,
        animated: Bool
    ) {
        if animated {
            tableView.reloadSections([section], with: .fade)
        } else {
            UIView.performWithoutAnimation {
                tableView.reloadSections([section], with: .none)
            }
        }
    }

    func refreshAll() {
        tableView.reloadData()
    }

    func renderQuickReply(props: QuickReplyView.Props) {
        quickReplyView.props = props
    }

    private func renderHeaderProps() {
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
    }

    @objc
    private func dismissKeyboard(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            endEditing(true)
        }
    }

    // swiftlint:disable function_body_length
    func content(for item: ChatItem) -> ChatItemCell.Content {
        switch item.kind {
        case .queueOperator:
            return .queueOperator(connectView)
        case let .outgoingMessage(message):
            return outgoingMessageContent(message)
        case let .visitorMessage(message, status):
            return visitorMessageContent(message, status: status)
        case let .operatorMessage(message, showsImage, imageUrl):
            return operatorMessageContent(
                message,
                showsImage: showsImage,
                imageUrl: imageUrl
            )
        case let .choiceCard(message, showsImage, imageUrl, isActive):
            return choiceCardMessageContent(
                message,
                showsImage: showsImage,
                imageUrl: imageUrl,
                isActive: isActive
            )
        case let .customCard(chatMessage, showsImage, imageUrl, isActive):
            return customCardContent(
                chatMessage,
                showsImage: showsImage,
                imageUrl: imageUrl,
                isActive: isActive
            )
        case let .callUpgrade(kind, duration):
            return callUpgradeContent(kind: kind, duration: duration)
        case let .operatorConnected(name, imageUrl):
            return operatorConnectedContent(name: name, imageUrl: imageUrl)
        case .transferring:
            return transferringContent()
        case .unreadMessageDivider:
            return unreadMessageDividerContent()
        case .systemMessage(let message):
            return systemMessageContent(message)
        case let .gvaPersistentButton(message, button, showImage, imageUrl):
            return gvaPersistentButtonContent(
                message,
                button: button,
                showImage: showImage,
                imageUrl: imageUrl
            )
        case let .gvaResponseText(message, text, showImage, imageUrl):
            let view = gvaResponseTextView(
                message,
                text: text.content,
                showImage: showImage,
                imageUrl: imageUrl
            )
            return .gvaResponseText(view)
        case let .gvaQuickReply(message, button, showImage, imageUrl):
            let view = gvaResponseTextView(
                message,
                text: button.content,
                showImage: showImage,
                imageUrl: imageUrl
            )
            return .gvaQuickReply(view)
        case let .gvaGallery(message, gallery, showImage, imageUrl):
            return gvaGalleryListViewContent(message, gallery: gallery, showsImage: showImage, imageUrl: imageUrl)
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

    func isBottomReached(for scrollView: UIScrollView) -> Bool {
        let chatBottomOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let currentPositionOffset = scrollView.contentOffset.y + scrollView.contentInset.top

        return currentPositionOffset >= chatBottomOffset
    }
}

// MARK: - WebMessageCardViewDelegate

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

// MARK: - Call Bubble

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

// MARK: - Keyboard

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

// MARK: - Message Content

extension ChatView {
    private func operatorMessageContent(
        _ message: ChatMessage,
        showsImage: Bool,
        imageUrl: String?
    ) -> ChatItemCell.Content {
        let view = OperatorChatMessageView(
            with: style.operatorMessageStyle,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiScreen: environment.uiScreen
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
            with: style.choiceCardStyle,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiScreen: environment.uiScreen
            )
        )
        let choiceCard = ChoiceCard(with: message, isActive: isActive)
        view.showsOperatorImage = showsImage
        view.setOperatorImage(fromUrl: imageUrl, animated: false)
        view.onOptionTapped = { self.choiceOptionSelected($0, message.id) }
        view.appendContent(.choiceCard(choiceCard), animated: false)
        return .choiceCard(view)
    }

    private func systemMessageContent(_ message: ChatMessage) -> ChatItemCell.Content {
        let view = SystemMessageView(
            with: style.systemMessageStyle,
            environment: .init(
                uiScreen: environment.uiScreen
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

        return .systemMessage(view)
    }

    private func outgoingMessageContent(_ message: OutgoingMessage) -> ChatItemCell.Content {
        let view = VisitorChatMessageView(
            with: style.visitorMessageStyle,
            environment: .init(uiScreen: environment.uiScreen)
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
    }

    private func visitorMessageContent(
        _ message: ChatMessage,
        status: String?
    ) -> ChatItemCell.Content {
        let view = VisitorChatMessageView(
            with: style.visitorMessageStyle,
            environment: .init(uiScreen: environment.uiScreen)
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
    }

    private func customCardContent(
        _ chatMessage: ChatMessage,
        showsImage: Bool,
        imageUrl: String?,
        isActive: Bool
    ) -> ChatItemCell.Content {
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
            if chatMessage.cardType == .choiceCard {
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
    }

    private func callUpgradeContent(
        kind: ObservableValue<CallKind>,
        duration: ObservableValue<Int>
    ) -> ChatItemCell.Content {
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
    }

    private func operatorConnectedContent(
        name: String?,
        imageUrl: String?
    ) -> ChatItemCell.Content {
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
    }

    private func transferringContent() -> ChatItemCell.Content {
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

    private func unreadMessageDividerContent() -> ChatItemCell.Content {
        let messageDivider = UnreadMessageDividerView(style: style.unreadMessageDivider)
        return .unreadMessagesDivider(messageDivider)
    }

    private func gvaResponseTextView(
        _ message: ChatMessage,
        text: NSMutableAttributedString,
        showImage: Bool,
        imageUrl: String?
    ) -> GvaResponseTextView {
        let view = GvaResponseTextView(
            with: style.operatorMessageStyle,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiScreen: environment.uiScreen
            )
        )
        view.appendContent(
            .attributedText(
                text,
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
        view.showsOperatorImage = showImage
        view.setOperatorImage(fromUrl: imageUrl, animated: false)
        return view
    }

    private func gvaPersistentButtonContent(
        _ message: ChatMessage,
        button: GvaButton,
        showImage: Bool,
        imageUrl: String?
    ) -> ChatItemCell.Content {
        let view = GvaPersistentButtonView(
            with: style,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiScreen: environment.uiScreen
            )
        )

        view.appendContent(
            .gvaPersistentButton(button),
            animated: false
        )

        view.appendContent(
            .downloads(
                message.downloads,
                accessibility: .init(from: .operator(message.operator?.name ?? style.accessibility.operator))),
            animated: false
        )
        view.onOptionTapped = { [weak self] in self?.gvaButtonTapped?($0) }
        view.downloadTapped = { [weak self] in self?.downloadTapped?($0) }
        view.linkTapped = { [weak self] in self?.linkTapped?($0) }
        view.showsOperatorImage = showImage
        view.setOperatorImage(fromUrl: imageUrl, animated: false)
        return .gvaPersistentButton(view)
    }
}
