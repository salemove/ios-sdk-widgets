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
            endScreenshareCmd: .init { [weak self] in self?.viewModel.event(.endScreenSharingTapped) },
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
        view.header.showCloseButton()

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
        view.messageEntryView.sendTapped = {
            viewModel.event(.sendTapped)
        }
        view.messageEntryView.pickMediaTapped = {
            viewModel.event(.pickMediaTapped)
        }
        view.fileTapped = { file in
            viewModel.event(.fileTapped(file))
        }
        view.downloadTapped = { download in
            viewModel.event(.downloadTapped(download))
        }
        view.callBubbleTapped = {
            viewModel.event(.callBubbleTapped)
        }
        view.choiceOptionSelected = { option, messageId in
            viewModel.event(.choiceOptionSelected(option, messageId))
        }
        view.chatScrolledToBottom = { bottomReached in
            viewModel.event(.chatScrolled(bottomReached: bottomReached))
        }
        view.linkTapped = { url in
            viewModel.event(.linkTapped(url))
        }
        view.selectCustomCardOption = { option, messageId in
            viewModel.event(.customCardOptionSelected(option: option, messageId: messageId))
        }

        view.gvaButtonTapped = { option in
            viewModel.event(.gvaButtonTapped(option))
        }

        view.retryMessageTapped = { message in
            viewModel.event(.retryMessageTapped(message))
        }

        var viewModel = viewModel

        viewModel.action = { [weak self, weak view] action in
            guard let self else { return }
            switch action {
            case .queue:
                view?.setConnectState(.queue, animated: false)
            case .connected(let name, let imageUrl):
                view?.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view?.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
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
                let style = self.environment.viewFactory.theme.snackBarStyle
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
        let endEvent = Cmd { [weak self] in
            self?.view.endEditing(true)
            viewModel.event(EngagementViewModel.Event.closeTapped)
        }
        let backEvent = Cmd { viewModel.event(EngagementViewModel.Event.backTapped) }
        let closeEvent = Cmd { viewModel.event(EngagementViewModel.Event.closeTapped) }
        let endScreenSharingEvent = Cmd { viewModel.event(EngagementViewModel.Event.endScreenSharingTapped) }

        let chatHeaderBackButton = chatTheme.header.backButton.map {
            HeaderButton.Props(tap: backEvent, style: $0)
        }

        let chatHeader = Header.Props(
            title: chatTheme.title,
            effect: .none,
            endButton: .init(style: chatTheme.header.endButton, tap: endEvent, accessibilityIdentifier: "header_end_button"),
            backButton: chatHeaderBackButton,
            closeButton: .init(tap: closeEvent, style: chatTheme.header.closeButton),
            endScreenshareButton: .init(tap: endScreenSharingEvent, style: chatTheme.header.endScreenShareButton),
            style: chatTheme.header
        )

        let secureTranscriptHeader = Header.Props(
            title: chatTheme.secureTranscriptTitle,
            effect: .none,
            endButton: .init(style: chatTheme.secureTranscriptHeader.endButton, tap: endEvent, accessibilityIdentifier: "header_end_button"),
            backButton: nil,
            closeButton: .init(tap: closeEvent, style: chatTheme.secureTranscriptHeader.closeButton),
            endScreenshareButton: .init(tap: endScreenSharingEvent, style: chatTheme.secureTranscriptHeader.endScreenShareButton),
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
