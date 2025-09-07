import Foundation

extension ChatViewModel: ViewModel {
    enum Event {
        case messageTextChanged(String)
        case removeUploadTapped(FileUpload)
        case pickMediaTapped
        case callBubbleTapped
        case fileTapped(LocalFile)
        case downloadTapped(FileDownload)

        case chatScrolled(bottomReached: Bool)
        case linkTapped(URL)
    }

    enum AsyncEvent {
        case viewDidLoad
        case sendTapped
        case customCardOptionSelected(
            option: HtmlMetadata.Option,
            messageId: MessageRenderer.Message.Identifier
        )
        case gvaButtonTapped(GvaOption)
        case retryMessageTapped(OutgoingMessage)
        case choiceOptionSelected(ChatChoiceCardOption, String)
    }

    enum Action {
        /// Actions specific for `TranscriptModel`.
        enum TranscriptAction {
            case messageCenterAvailabilityUpdated
        }
        case enqueueing
        case enqueued
        case connected(name: String?, imageUrl: String?)
        case transferring
        case setMessageEntryEnabled(Bool)
        case setChoiceCardInputModeEnabled(Bool)
        case setMessageText(String)
        case sendButtonDisabled(Bool)
        case pickMediaButtonEnabled(Bool)
        case appendRows(Int, to: Int, animated: Bool)
        case refreshRow(Int, in: Int, animated: Bool)
        case refreshRows([Int], in: Int, animated: Bool)
        case refreshSection(Int, animated: Bool = false)
        case deleteRows([Int], in: Int, animated: Bool)
        case refreshAll
        case scrollToBottom(animated: Bool)
        case updateItemsUserImage(animated: Bool)
        case addUpload(FileUpload)
        case removeUpload(FileUpload)
        case removeAllUploads
        case presentMediaPicker(itemSelected: (AttachmentSourceItemKind) -> Void)
        case showCallBubble(imageUrl: String?)
        case setCallBubbleImage(imageUrl: String?)
        case updateUnreadMessageIndicator(itemCount: Int)
        case setUnreadMessageIndicatorImage(imageUrl: String?)
        case setOperatorTypingIndicatorIsHiddenTo(Bool, _ isChatScrolledToBottom: Bool)
        case setAttachmentButtonEnabling(MediaPickerButtonEnabling)
        case fileUploadListPropsUpdated(SecureConversations.FileUploadListView.Props)
        case quickReplyPropsUpdated(QuickReplyView.Props)
        case transcript(TranscriptAction)
        case showSnackBarView
        case switchToEngagement
        case setMessageEntryConnected(Bool)
    }

    enum DelegateEvent {
        case pickMedia(ObservableValue<MediaPickerEvent>)
        case takeMedia(ObservableValue<MediaPickerEvent>)
        case pickFile(ObservableValue<FilePickerEvent>)
        case mediaUpgradeAccepted(
            offer: CoreSdkClient.MediaUpgradeOffer,
            answer: CoreSdkClient.AnswerWithSuccessBlock
        )
        case secureTranscriptUpgradedToLiveChat(ChatViewController)
        case showFile(LocalFile)
        case call
        case minimize
    }

    enum AsyncDelegateEvent {
        case liveChatEngagementUpgradedToSecureMessaging(ChatViewModel)
    }

    enum StartAction {
        case startEngagement
        case none
    }

    enum ChatType: Equatable {
        case secureTranscript(upgradedFromChat: Bool)
        case authenticated
        case nonAuthenticated
    }
}
