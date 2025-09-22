import MobileCoreServices
import UIKit

final class ChatViewController: EngagementViewController, PopoverPresenter {
    private(set) var viewModel: SecureConversations.ChatWithTranscriptModel {
        didSet {
            renderProps()
        }
    }
    private let environment: Environment
    private var lastVisibleRowIndexPath: IndexPath?

    init(
        viewModel: SecureConversations.ChatWithTranscriptModel,
        environment: Environment
    ) {
        self.viewModel = viewModel
        self.environment = environment

        super.init(
            viewModel: viewModel.engagementModel,
            environment: .create(with: environment)
        )
    }

    override public func loadView() {
        let view = viewFactory.makeChatView(
            endCmd: .init { [weak self] in self?.viewModel.event(.closeTapped) },
            closeCmd: .init { [weak self] in self?.viewModel.event(.closeTapped) },
            backCmd: .init { [weak self] in self?.viewModel.event(.backTapped) }
        )
        self.view = view

        bind(viewModel: viewModel, to: view)
        renderProps()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This is called to update message entry view height
        // on every font size change
        (self.view as? ChatView)?.messageEntryView.updateLayout()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewFactory.theme.chat.preferredStatusBarStyle
    }

    // swiftlint:disable function_body_length
    private func bind(viewModel: SecureConversations.ChatWithTranscriptModel, to view: ChatView) {
        view.entryWidget = viewModel.entryWidget

        view.header.showBackButton()

        let type = Self.currentChatModelType(viewModel)
        switch type {
        case .chat:
            view.header.hideCloseAndEndButtons()
        case .secureTranscript, .chatToSecureTranscript:
            view.header.showCloseButton()
        }

        view.numberOfSections = {
            viewModel.numberOfSections
        }
        view.numberOfRows = { rows in
            viewModel.numberOfItems(in: rows)
        }
        view.itemForRow = { row, section in
            viewModel.item(for: row, in: section)
        }
        view.messageEntryView.textChanged = { text in
            viewModel.event(.messageTextChanged(text))
        }
        view.messageEntryView.sendTapped = { [weak self] in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(OtelButtonNames.send.rawValue)
            }
            viewModel.event(.sendTapped)
        }
        view.messageEntryView.pickMediaTapped = { [weak self] in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(OtelButtonNames.addAttachment.rawValue)
            }
            viewModel.event(.pickMediaTapped)
        }
        view.fileTapped = { file in
            viewModel.event(.fileTapped(file))
        }
        view.downloadTapped = { [weak self] download in
            guard let self else { return }
            environment.openTelemetry.logger.i(.chatScreenFileDownloading) {
                $0[.fileId] = .string(download.file.id ?? "null")
            }
            download.state.addObserver(self) { [weak self] state, _ in
                if case .downloaded = state {
                    self?.environment.openTelemetry.logger.i(.chatScreenFileDownloaded) {
                        $0[.fileId] = .string(download.file.id ?? "null")
                    }
                }
            }
            viewModel.event(.downloadTapped(download))
        }
        view.callBubbleTapped = {
            viewModel.event(.callBubbleTapped)
        }
        view.choiceOptionSelected = { [weak self] option, messageId in
            self?.environment.openTelemetry.logger.i(.chatScreenSingleChoiceAnswered) {
                $0[.messageId] = .string(messageId)
            }
            viewModel.event(.choiceOptionSelected(option, messageId))
        }
        view.chatScrolledToBottom = { bottomReached in
            viewModel.event(.chatScrolled(bottomReached: bottomReached))
        }
        view.linkTapped = { url in
            viewModel.event(.linkTapped(url))
        }
        view.selectCustomCardOption = { [weak self] option, messageId in
            self?.environment.openTelemetry.logger.i(.chatScreenCustomCardAction) {
                $0[.messageId] = .string(messageId.rawValue)
            }
            viewModel.event(.customCardOptionSelected(option: option, messageId: messageId))
        }

        view.gvaButtonTapped = { [weak self] option in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(OtelButtonNames.gva.rawValue)
            }
            viewModel.event(.gvaButtonTapped(option))
        }

        view.retryMessageTapped = { [weak self] message in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(OtelButtonNames.retry.rawValue)
            }
            viewModel.event(.retryMessageTapped(message))
        }

        var viewModel = viewModel

        viewModel.action = { [weak self, weak view] action in
            guard let self else { return }
            switch action {
            case .enqueueing:
                view?.setConnectState(.queue, animated: false)
            case .enqueued:
                view?.header.showCloseButton()
            case .connected(let name, let imageUrl):
                view?.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view?.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
                view?.header.showEndButton()
                self.viewModel.action?(.setMessageEntryConnected(true))
            case .setMessageEntryEnabled(let enabled):
                view?.messageEntryView.isEnabled = enabled
            case .setChoiceCardInputModeEnabled(let enabled):
                view?.messageEntryView.isChoiceCardModeEnabled = enabled
            case .setMessageText(let text):
                view?.messageEntryView.messageText = text
            case .sendButtonDisabled(let isDisabled):
                view?.messageEntryView.isSendButtonEnabled = !isDisabled
            case .pickMediaButtonEnabled(let enabled):
                view?.messageEntryView.pickMediaButton.isEnabled = enabled
            case .appendRows(let count, let section, let animated):
                view?.appendRows(count, to: section, animated: animated)
            case .refreshRow(let row, let section, let animated):
                view?.refreshRow(row, in: section, animated: animated)
            case .refreshRows(let rows, let section, let animated):
                view?.refreshRows(rows, in: section, animated: animated)
            case let .refreshSection(section, animated):
                view?.refreshSection(section, animated: animated)
            case let .deleteRows(rows, in: section, animated: animated):
                view?.deleteRows(rows, in: section, animated: animated)
            case .refreshAll:
                view?.refreshAll()
            case .scrollToBottom(let animated):
                view?.scrollToBottom(animated: animated)
            case .updateItemsUserImage(let animated):
                view?.updateItemsUserImage(animated: animated)
            case .addUpload:
                // Handled by data-driven SecureConversations.FileUploadListView.
                break
            case .removeUpload:
                // Handled by data-driven SecureConversations.FileUploadListView.
                break
            case .removeAllUploads:
                view?.messageEntryView.uploadListView.removeAllUploadViews()
            case .presentMediaPicker(let itemSelected):
                guard let view = view else { return }
                self.presentMediaPicker(
                    from: view.messageEntryView.pickMediaButton,
                    itemSelected: itemSelected
                )
            case .showCallBubble(let imageUrl):
                view?.showCallBubble(with: imageUrl, animated: true)
            case .updateUnreadMessageIndicator(let count):
                view?.unreadMessageIndicatorView.newItemCount = count
            case .setOperatorTypingIndicatorIsHiddenTo(let isHidden, let isChatScrolledToBottom):
                if isChatScrolledToBottom {
                    view?.scrollToBottom(animated: true)
                }
                view?.setOperatorTypingIndicatorIsHidden(to: isHidden)
            case let .setAttachmentButtonEnabling(visibility):
                view?.messageEntryView.setPickMediaButtonVisibility(visibility)
            case .transferring:
                view?.setConnectState(.transferring, animated: true)
            case .setCallBubbleImage(let imageUrl):
                view?.setCallBubbleImage(with: imageUrl)
            case .setUnreadMessageIndicatorImage(let imageUrl):
                view?.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
            case let .fileUploadListPropsUpdated(fileUploadListProps):
                view?.messageEntryView.uploadListView.props = fileUploadListProps
            case let .quickReplyPropsUpdated(props):
                view?.renderQuickReply(props: props)
            case .transcript(.messageCenterAvailabilityUpdated):
                break
            case .showSnackBarView:
                let style = self.environment.viewFactory.theme.snackBar
                self.environment.snackBar.present(
                    text: style.text,
                    style: style,
                    for: self,
                    bottomOffset: -128,
                    timerProviding: self.environment.timerProviding,
                    gcd: self.environment.gcd,
                    notificationCenter: self.environment.notificationCenter
                )
            case .switchToEngagement:
                view?.hideEntryWidget()
            case let .setMessageEntryConnected(isConnected):
                view?.messageEntryView.isConnected = isConnected
            }
            self.renderProps()
        }
    }
    // swiftlint:enable function_body_length

    private func presentMediaPicker(
        from sourceView: UIView,
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    ) {
        presentPopover(
            with: viewFactory.theme.chat.pickMedia,
            from: sourceView,
            itemSelected: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                itemSelected($0)
            }
        )
    }

    private func props(
        using viewModel: SecureConversations.ChatWithTranscriptModel
    ) -> ChatViewController.Props {
        let chatTheme = viewFactory.theme.chat
        let logButtonClickedEvent: (OtelButtonNames) -> Void = { [weak self] buttonName in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                $0[.buttonName] = .string(buttonName.rawValue)
            }
        }
        let endEvent = Cmd { [weak self] in
            self?.view.endEditing(true)
            logButtonClickedEvent(.end)
            viewModel.event(EngagementViewModel.Event.closeTapped)
        }
        let backEvent = Cmd {
            logButtonClickedEvent(.back)
            viewModel.event(EngagementViewModel.Event.backTapped)
        }
        let closeEvent = Cmd {
            logButtonClickedEvent(.close)
            viewModel.event(EngagementViewModel.Event.closeTapped)
        }

        let chatHeaderBackButton = chatTheme.header.backButton.map {
            HeaderButton.Props(tap: backEvent, style: $0)
        }

        let chatHeader = Header.Props(
            title: chatTheme.title,
            effect: .none,
            endButton: .init(style: chatTheme.header.endButton, tap: endEvent, accessibilityIdentifier: "header_end_button"),
            backButton: chatHeaderBackButton,
            closeButton: .init(tap: closeEvent, style: chatTheme.header.closeButton),
            style: chatTheme.header
        )

        let secureTranscriptHeader = Header.Props(
            title: chatTheme.secureTranscriptTitle,
            effect: .none,
            endButton: .init(style: chatTheme.secureTranscriptHeader.endButton, tap: endEvent, accessibilityIdentifier: "header_end_button"),
            backButton: nil,
            closeButton: .init(tap: closeEvent, style: chatTheme.secureTranscriptHeader.closeButton),
            style: chatTheme.secureTranscriptHeader
        )

        return .init(chat: chatHeader, secureTranscript: secureTranscriptHeader)
    }

    private func renderProps() {
        guard let chatView: ChatView = view as? ChatView else { return }

        let type = Self.currentChatModelType(viewModel)
        let props = props(using: viewModel)

        switch type {
        case .chat:
            chatView.setIsTopBannerAllowed(false)
            chatView.props = .init(header: props.chat)
            // For regular chat engagement bottom banner is hidden.
            chatView.setSecureMessagingBottomBannerHidden(true)
            chatView.setSendingMessageUnavailabilityBannerHidden(viewModel.isSendMessageAvailable)
        case let .secureTranscript(needsTextInputEnabled):
            chatView.setIsTopBannerAllowed(true)
            chatView.props = .init(header: props.secureTranscript)
            // Instead of hiding text input, we need to disable it and corresponding buttons.
            chatView.messageEntryView.isEnabled = needsTextInputEnabled
            chatView.setSendingMessageUnavailabilityBannerHidden(viewModel.isSendMessageAvailable)
            // For secure messaging bottom banner is visible.
            chatView.setSecureMessagingBottomBannerHidden(false)
        case .chatToSecureTranscript:
            chatView.setIsTopBannerAllowed(true)
            chatView.props = .init(header: props.secureTranscript)
            chatView.messageEntryView.isEnabled = true
            chatView.setSendingMessageUnavailabilityBannerHidden(true)
            chatView.setSecureMessagingBottomBannerHidden(false)
        }
    }

    deinit {
        viewModel.environment.log.prefixed(Self.self).info("Destroy Chat screen")
    }
}

extension ChatViewController {
    func swapAndBindViewModel(_ viewModel: SecureConversations.ChatWithTranscriptModel) {
        // Binding is only possible for `ChatView` so casting is required.
        guard let chatView = view as? ChatView else { return }
        // Swap transcript model with chat model.
        self.viewModel = viewModel
        // Swap existing engagement transcript model
        // (though it is technically not for engagement)
        // with engagement chat model in superclass EngagementViewController.
        swapAndBindEngagementViewModel(viewModel.engagementModel)
        // Bind chat model to chat view for sending actions
        // and receiving events.
        bind(
            viewModel: viewModel,
            to: chatView
        )
    }

    private static func currentChatModelType(
        _ viewModel: SecureConversations.ChatWithTranscriptModel
    ) -> CurrentChatModelType {
        switch viewModel {
        case .chat(let chatViewModel):
            // Even though we are using the chat view model already,
            // if the engagement is not active, we still need to show
            // secure transcript UI.
            switch chatViewModel.chatType {
            case let .secureTranscript(upgradedFromChat):
                if upgradedFromChat {
                    return .chatToSecureTranscript
                }
                return chatViewModel.activeEngagement != nil
                ? .chat
                : .secureTranscript(needsTextInputEnabled: true)
            case .authenticated, .nonAuthenticated:
                return .chat
            }
        case .transcript(let transcriptModel):
            return .secureTranscript(needsTextInputEnabled: transcriptModel.isSecureConversationsAvailable)
        }
    }
}

extension ChatViewController {
    struct Props: Equatable {
        let chat: Header.Props
        let secureTranscript: Header.Props
    }
}
private enum CurrentChatModelType {
    case chat
    case secureTranscript(needsTextInputEnabled: Bool)
    case chatToSecureTranscript
}
