import UIKit
import Combine

extension ChatView {
    struct Props {
        let header: Header.Props
    }
}

// swiftlint:disable file_length
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
    var choiceOptionSelected: ((ChatChoiceCardOption, String) async -> Void)!
    var chatScrolledToBottom: ((Bool) -> Void)?
    var linkTapped: ((URL) -> Void)?
    var selectCustomCardOption: ((HtmlMetadata.Option, MessageRenderer.Message.Identifier) async -> Void)?
    var gvaButtonTapped: ((GvaOption) async -> Void)?
    var retryMessageTapped: ((OutgoingMessage) async -> Void)?
    lazy var secureMessagingTopBannerView = SecureMessagingTopBannerView(
        isExpanded: $isTopBannerExpanded,
        environment: .create(with: environment)
    ).makeView()
    let entryWidgetContainerView = UIView().makeView()
    let entryWidgetOverlayView = OverlayView().makeView()
    let secureMessagingBottomBannerView = SecureMessagingBottomBannerView().makeView()
    let sendingMessageUnavailabilityBannerView = SendingMessageUnavailableBannerView().makeView()
    private var didForceInitialTableLayout = false
    // Instead of modifying message entry view's layout to resize, covering bottom safe area,
    // thus affecting existing layout calculations, we add additional view just for that,
    // keeping background color for it reactively in sync with message entry view's one.
    lazy var messageEntryBottomArea = UIView().makeView { [weak messageEntryView] area in
        messageEntryView?.publisher(for: \.backgroundColor).sink { [weak area] newColor in
            area?.backgroundColor = newColor
        }.store(in: &cancelBag)
    }

    let style: ChatStyle
    let environment: Environment

    var entryWidget: EntryWidget? {
        didSet {
            observeEntryWidget(entryWidget)
        }
    }
    lazy var quickReplyView = QuickReplyView(
        style: style.gliaVirtualAssistant.quickReplyButton
    )
    private lazy var connectView: ChatConnectViewHost = {
        ChatConnectViewHost(
            connectStyle: style.connect,
            imageCache: environment.imageViewCache
        )
    }()
    var messageEntryViewBottomConstraint: NSLayoutConstraint?
    var entryWidgetContainerViewHeightConstraint: NSLayoutConstraint?
    private var callBubble: BubbleView?
    private let keyboardObserver = KeyboardObserver()
    private let messageRenderer: MessageRenderer?
    private var heightCache: [String: CGFloat] = [:]
    private var callBubbleBounds: CGRect {
        let x = safeAreaInsets.left + Constants.callBubbleEdgeInset
        let y = safeAreaInsets.top + Constants.callBubbleEdgeInset
        let width = frame.width - safeAreaInsets.left - safeAreaInsets.right - 2 * Constants.callBubbleEdgeInset
        let height = messageEntryView.frame.maxY - safeAreaInsets.top - 2 * Constants.callBubbleEdgeInset

        return CGRect(x: x, y: y, width: width, height: height)
    }

    let topContentShadowView = UIView()
    let topContentShadowGradient = CAGradientLayer()
    // Made internal for Snapshot test purposes
    @Published private(set) var isTopBannerExpanded = false
    @Published private(set) var isTopBannerHidden = true
    @Published private(set) var isTopBannerAllowed = false

    var props: Props {
        didSet { renderHeaderProps() }
    }

    private var cancelBag = CancelBag()

    /// If not nil, represents a snackbar that should be shown
    /// once ChatView is actually in the view hierarchy.
    var pendingSnackBar: PendingSnackBar?

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
            environment: .create(with: environment)
        )
        self.unreadMessageIndicatorView = UnreadMessageIndicatorView(
            with: style.unreadMessageIndicator,
            environment: .create(with: environment)
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
            environment: .create(with: environment),
            headerProps: props.header
        )
        self.accessibilityIdentifier = "chat_root_view"
    }

    required init() { fatalError("init() has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        moveCallBubbleVisible()
        topContentShadowGradient.frame = topContentShadowView.bounds
        topContentShadowGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        topContentShadowGradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
        topContentShadowGradient.colors = [
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        topContentShadowGradient.locations = [0, 1]

        // UIHostingController-backed content does not resolve its intrinsic
        // content size on the first layout pass, which can cause the initial table row
        // height to be incorrect. Trigger a one-time reload once the view has a real size.
        forceInitialTableLayoutIfNeeded()
    }

    override func setup() {
        super.setup()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = Constants.chatTableViewInsets
        tableView.register(cell: ChatItemCell.self)
        unreadMessageIndicatorView.tapped = { [weak self] in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(OtelButtonNames.newMessagesIndicator.rawValue)
            }
            self?.scrollToBottom(animated: true)
        }
        tableAndIndicatorStack.axis = .vertical
        observeKeyboard()
        addKeyboardDismissalTapGesture()
        typingIndicatorView.accessibilityIdentifier = "chat_typingIndicator"
        typingIndicatorContainer.isHidden = true
        bindTopBanner()
        // Hide secure conversation bottom banner unavailability banner initially.
        setSecureMessagingBottomBannerHidden(true)
        setSecureMessagingTopBannerHidden(true)
        setSendingMessageUnavailabilityBannerHidden(true)
    }

    override func defineLayout() {
        super.defineLayout()
        setupConstraints()
    }

    private func forceInitialTableLayoutIfNeeded() {
        guard !didForceInitialTableLayout else { return }
        guard window != nil else { return }
        guard tableView.bounds.width > 0, tableView.bounds.height > 0 else { return }
        didForceInitialTableLayout = true
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + 0.1) {
            self.tableView.reloadData()
        }
    }
}

extension ChatView {
    func setSendingMessageUnavailabilityBannerHidden(_ isHidden: Bool) {
        sendingMessageUnavailabilityBannerView.props = .init(
            style: style.sendingMessageUnavailableBannerViewStyle,
            isHidden: isHidden
        )
    }

    func setSecureMessagingTopBannerHidden(_ isHidden: Bool) {
        secureMessagingTopBannerView.props = .init(
            style: style.secureMessagingTopBannerStyle,
            buttonTap: topBannerViewButtonCommand(),
            isHidden: isHidden
        )
    }

    func setSecureMessagingBottomBannerHidden(_ isHidden: Bool) {
        secureMessagingBottomBannerView.props = .init(
            style: style.secureMessagingBottomBannerStyle,
            isHidden: isHidden
        )
    }

    func setOperatorTypingIndicatorIsHidden(to isHidden: Bool) {
        typingIndicatorContainer.isHidden = isHidden
    }

    func setConnectState(_ state: EngagementState, animated: Bool) {
        connectView.setState(state)
        updateTableView(animated: animated)
    }

    func updateItemsUserImage(animated: Bool) {
        // Prevent breaking autolayout.
        guard self.frame != .zero else {
            return
        }
        tableView.indexPathsForVisibleRows?.forEach {
            if let cell = tableView.cellForRow(at: $0) as? ChatItemCell,
               let item = itemForRow?($0.row, $0.section) {
                switch cell.content {
                case .operatorMessage(let view):
                    guard case let .operatorMessage(message, showsImage, imageUrl) = item.kind else { return }
                    // forward operator name to typing indicator's accessibility
                    if let operatorName = message.operator?.name {
                        typingIndicatorView.accessibilityProperties.operatorName = operatorName
                    }

                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                case .choiceCard(let view):
                    guard case let .choiceCard(_, showsImage, imageUrl, _) = item.kind else { return }
                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                case let .gvaGallery(view, _):
                    guard case let .gvaGallery(_, _, showsImage, imageUrl) = item.kind else { return }
                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                case let .gvaQuickReply(view):
                    guard case let .gvaQuickReply(_, _, showsImage, imageUrl) = item.kind else { return }
                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                case let .gvaResponseText(view):
                    guard case let .gvaResponseText(_, _, showsImage, imageUrl) = item.kind else { return }
                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                case let .gvaPersistentButton(view):
                    guard case let .gvaPersistentButton(_, _, showsImage, imageUrl) = item.kind else { return }
                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                case let .customCard(view):
                    guard case let .customCard(_, showsImage, imageUrl, _) = item.kind else { return }
                    view.showsOperatorImage = showsImage
                    view.setOperatorImage(fromUrl: imageUrl, animated: animated)
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
        // Prevent breaking autolayout.
        guard self.frame != .zero else {
            return
        }
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

    func deleteRows(_ rows: [Int], in section: Int, animated: Bool) {
        tableView.deleteRows(rows, in: section, animated: animated)
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
        case let .outgoingMessage(message, error):
            return outgoingMessageContent(message, error: error)
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
        case .operatorConnected:
            return operatorConnectedContent()
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

    private func bindTopBanner() {
        $isTopBannerExpanded
            .sink { [weak self] isExpanded in
                self?.setEntryWidgetExpanded(isExpanded)
            }
            .store(in: &cancelBag)
        $isTopBannerHidden
            .sink { [weak self] isHidden in
                self?.setSecureMessagingTopBannerHidden(isHidden)
            }
            .store(in: &cancelBag)
    }

    private func topBannerViewButtonCommand() -> Command<Bool> {
        .init { [weak self] isExpanded in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(OtelButtonNames.scTopBanner.rawValue)
            }
            self?.isTopBannerExpanded = isExpanded
        }
    }

    private func setEntryWidgetExpanded(_ isExpanded: Bool) {
        if isExpanded {
            showEntryWidget()
        } else {
            hideEntryWidget()
        }
    }

    private func showEntryWidget() {
        guard let entryWidgetContainerViewHeightConstraint else {
            return
        }

        entryWidget?.embed(in: entryWidgetContainerView)
        layoutIfNeeded()

        entryWidgetOverlayView.show()
        NSLayoutConstraint.deactivate([entryWidgetContainerViewHeightConstraint])
        UIView.animate(withDuration: Constants.topBannerViewAnimationDuration) { [weak self] in
            self?.entryWidgetOverlayView.alpha = 1
            self?.layoutIfNeeded()
        }

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(entryWidgetTapGestureAction)
        )
        addGestureRecognizer(tapGesture)
    }

    func hideEntryWidget() {
        guard let entryWidgetContainerViewHeightConstraint else {
            return
        }

        NSLayoutConstraint.activate([entryWidgetContainerViewHeightConstraint])
        entryWidgetContainerView.subviews.forEach { $0.removeFromSuperview() }

        UIView.animate(
            withDuration: Constants.topBannerViewAnimationDuration,
            animations: { [weak self] in
                self?.entryWidgetOverlayView.alpha = 0
                self?.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.entryWidgetOverlayView.hide()
            }
        )
    }

    private func observeEntryWidget(_ entryWidget: EntryWidget?) {
        guard let entryWidget else {
            return
        }
        let isAnyEngagementTypeAvailable = entryWidget.$viewState
            .map {
                if case let .mediaTypes(availableMediaTypes) = $0 {
                    return availableMediaTypes
                }
                return []
            }
            .map { !$0.isEmpty }
        isAnyEngagementTypeAvailable
            .filter { !$0 }
            .assign(to: &$isTopBannerExpanded)

        Publishers.CombineLatest(isAnyEngagementTypeAvailable, $isTopBannerAllowed)
            .map { typesAvailable, isTopBannerAllowed in
                // If top banner is explicitly not allowed, then there's no need to
                // evaluate available types, and we just early out hiding top banner.
                if !isTopBannerAllowed {
                    return true
                }
                // We also hide top banner, if no appropriate media types are available.
                return !typesAvailable
            }
            .assign(to: &$isTopBannerHidden)
    }

    func setIsTopBannerAllowed(_ isTopBannerAllowed: Bool) {
        self.isTopBannerAllowed = isTopBannerAllowed
    }

    @objc private func entryWidgetTapGestureAction() {
        hideEntryWidget()
        isTopBannerExpanded = false
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
        Task {
            await selectCustomCardOption?(selectedOption, messageId)
        }
    }

    func didCallMobileAction(_ view: WebMessageCardView, action: String) {
        messageRenderer?.callMobileActionHandler(action)
    }

    func didSelectURL(_ view: WebMessageCardView, url: URL) {
        linkTapped?(url)
    }

    private func isLastMessage(_ messageId: MessageRenderer.Message.Identifier) -> Bool {
        let numberOfSections = { [weak self] in self?.numberOfSections?() ?? 0 }
        let numberOfRows = { [weak self] section in self?.numberOfRows?(section) ?? 0 }
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
            environment: .create(with: environment)
        )
        callBubble.kind = .userImage(url: imageUrl)
        callBubble.tap = { [weak self] in self?.callBubbleTapped?() }
        callBubble.pan = { [weak self] in self?.moveCallBubble($0, animated: true) }
        callBubble.frame = CGRect(
            origin: CGPoint(
                x: callBubbleBounds.maxX - Constants.callBubbleSize.width,
                y: callBubbleBounds.maxY - Constants.callBubbleSize.height
            ),
            size: Constants.callBubbleSize
        )
        self.callBubble = callBubble

        addSubview(callBubble)

        environment.openTelemetry.logger.i(.bubbleShown)
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
        keyboardObserver.keyboardWillShow = { [weak self] properties in
            guard let self else { return }

            let bottomInset = self.safeAreaInsets.bottom
            let newEntryConstraint = -properties.finalFrame.height + bottomInset

            UIView.animate(
                withDuration: properties.duration,
                delay: 0.0,
                options: properties.animationOptions,
                animations: { [weak self] in
                    self?.messageEntryViewBottomConstraint?.constant = newEntryConstraint
                    self?.layoutIfNeeded()
                },
                completion: { [weak self] _ in
                    self?.tableView.scrollToBottom(animated: true)
                }
            )
        }

        keyboardObserver.keyboardWillHide = { [weak self] properties in
            UIView.animate(
                withDuration: properties.duration,
                delay: 0.0,
                options: properties.animationOptions,
                animations: { [weak self] in
                    self?.messageEntryViewBottomConstraint?.constant = 0
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
            environment: .create(with: environment)
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
                accessibility: .init(
                    from: .operator(message.operator?.name ?? style.accessibility.operator)
                )
            ),
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
            environment: .create(with: environment)
        )
        let choiceCard = ChoiceCard(with: message, isActive: isActive)
        view.showsOperatorImage = showsImage
        view.setOperatorImage(fromUrl: imageUrl, animated: false)
        view.onOptionTapped = { [weak self] in await self?.choiceOptionSelected($0, message.id) }
        view.appendContent(.choiceCard(choiceCard), animated: false)
        return .choiceCard(view)
    }

    private func systemMessageContent(_ message: ChatMessage) -> ChatItemCell.Content {
        let view = SystemMessageView(
            with: style.systemMessageStyle,
            environment: .create(with: environment)
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

    private func outgoingMessageContent(
        _ message: OutgoingMessage,
        error: String?
    ) -> ChatItemCell.Content {
        let view = VisitorChatMessageView(
            with: style.visitorMessageStyle,
            environment: .create(with: environment)
        )
        view.appendContent(
            .text(
                message.payload.content,
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
        view.error = error
        if error != nil {
            view.messageTapped = { [weak self] in
                await self?.retryMessageTapped?(message)
            }
        }
        return .outgoingMessage(view)
    }

    private func visitorMessageContent(
        _ message: ChatMessage,
        status: String?
    ) -> ChatItemCell.Content {
        let view = VisitorChatMessageView(
            with: style.visitorMessageStyle,
            environment: .create(with: environment)
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
            // if metadata can't be handled and
            // the message has single_choice attachment type
            // then handle it as Response card
            if chatMessage.attachment?.type == .singleChoice {
                return choiceCardMessageContent(
                    chatMessage,
                    showsImage: showsImage,
                    imageUrl: imageUrl,
                    isActive: isActive
                )
            }
            // otherwise handle as regular operator message
            return operatorMessageContent(
                chatMessage,
                showsImage: showsImage,
                imageUrl: imageUrl
            )
        }

        let container = CustomCardContainerView(
            style: style.operatorMessageStyle.operatorImage,
            environment: .create(with: environment)
        )
        if let webCardView = contentView as? WebMessageCardView {
            webCardView.isUserInteractionEnabled = isActive
            webCardView.delegate = self
            webCardView.updateHeight(heightCache[chatMessage.id] ?? 0)
            container.willDisplayView = webCardView.startLoading
        }

        container.addContentView(contentView)
        container.showsOperatorImage = showsImage
        container.setOperatorImage(fromUrl: imageUrl, animated: false)
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

    private func operatorConnectedContent() -> ChatItemCell.Content {
        return .queueOperator(connectView)
    }

    private func transferringContent() -> ChatItemCell.Content {
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
            environment: .create(with: environment)
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
                accessibility: .init(from: .operator(message.operator?.name ?? style.accessibility.operator))
            ),
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
            environment: .create(with: environment)
        )

        view.appendContent(
            .gvaPersistentButton(button),
            animated: false
        )

        view.appendContent(
            .downloads(
                message.downloads,
                accessibility: .init(from: .operator(message.operator?.name ?? style.accessibility.operator))
            ),
            animated: false
        )
        view.onOptionTapped = { [weak self] in await self?.gvaButtonTapped?($0) }
        view.downloadTapped = { [weak self] in self?.downloadTapped?($0) }
        view.linkTapped = { [weak self] in self?.linkTapped?($0) }
        view.showsOperatorImage = showImage
        view.setOperatorImage(fromUrl: imageUrl, animated: false)
        return .gvaPersistentButton(view)
    }
}

extension ChatView {
    struct PendingSnackBar {
        let text: String
        let style: Theme.SnackBarStyle
        let dismissTiming: SnackBar.DismissTiming
    }
}

#if DEBUG
extension ChatView {
    func setIsTopBannerExpanded(_ isTopBannerExpanded: Bool) {
        self.isTopBannerExpanded = isTopBannerExpanded
    }
}
#endif
// swiftlint:enable file_length
