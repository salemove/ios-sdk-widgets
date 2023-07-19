import MobileCoreServices
import UIKit

final class ChatViewController: EngagementViewController, PopoverPresenter {
    private var viewModel: SecureConversations.ChatWithTranscriptModel {
        didSet {
            renderProps()
        }
    }
    private var lastVisibleRowIndexPath: IndexPath?

    init(
        viewModel: SecureConversations.ChatWithTranscriptModel,
        viewFactory: ViewFactory
    ) {
        self.viewModel = viewModel

        super.init(viewModel: viewModel.engagementModel, viewFactory: viewFactory)
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

        var viewModel = viewModel

        viewModel.action = { [weak self, weak view] action in
            switch action {
            case .queue:
                view?.setConnectState(.queue, animated: false)
            case .connected(let name, let imageUrl):
                view?.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view?.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
                view?.messageEntryView.isConnected = true
            case .setMessageEntryEnabled(let enabled):
                view?.messageEntryView.isEnabled = enabled
            case .setChoiceCardInputModeEnabled(let enabled):
                view?.messageEntryView.isChoiceCardModeEnabled = enabled
            case .setMessageText(let text):
                view?.messageEntryView.messageText = text
            case .sendButtonHidden(let hidden):
                view?.messageEntryView.showsSendButton = !hidden
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
                self?.presentMediaPicker(
                    from: view.messageEntryView.pickMediaButton,
                    itemSelected: itemSelected
                )
            case .offerMediaUpgrade(let conf, let accepted, let declined):
                self?.offerMediaUpgrade(with: conf, accepted: accepted, declined: declined)
            case .showCallBubble(let imageUrl):
                view?.showCallBubble(with: imageUrl, animated: true)
            case .updateUnreadMessageIndicator(let count):
                view?.unreadMessageIndicatorView.newItemCount = count
            case .setOperatorTypingIndicatorIsHiddenTo(let isHidden, let isChatScrolledToBottom):
                if isChatScrolledToBottom {
                    view?.scrollToBottom(animated: true)
                }
                view?.setOperatorTypingIndicatorIsHidden(to: isHidden)
            case let .setAttachmentButtonVisibility(visibility):
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
            }
            self?.renderProps()
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
            arrowDirections: [.down],
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
        let endEvent = Cmd { viewModel.event(EngagementViewModel.Event.closeTapped) }
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
            chatView.props = .init(header: props.chat)
        case let .secureTranscript(needsTextInput):
            chatView.props = .init(header: props.secureTranscript)
            chatView.messageEntryView.isHidden = !needsTextInput
        }
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
        swapAndBindEgagementViewModel(viewModel.engagementModel)
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
            if chatViewModel.shouldSkipEnqueueingState {
                return chatViewModel.activeEngagement != nil
                ? .chat
                : .secureTranscript(needsTextInput: true)
            } else {
                return .chat
            }
        case .transcript(let transcriptModel):
            return .secureTranscript(needsTextInput: transcriptModel.isSecureConversationsAvailable)
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
    case secureTranscript(needsTextInput: Bool)
}
