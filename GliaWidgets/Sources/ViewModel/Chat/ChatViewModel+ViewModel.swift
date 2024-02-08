import Foundation

extension ChatViewModel: ViewModel {
    enum Event {
        case viewDidLoad
        case messageTextChanged(String)
        case sendTapped
        case removeUploadTapped(FileUpload)
        case pickMediaTapped
        case callBubbleTapped
        case fileTapped(LocalFile)
        case downloadTapped(FileDownload)
        case choiceOptionSelected(ChatChoiceCardOption, String)
        case chatScrolled(bottomReached: Bool)
        case linkTapped(URL)
        case customCardOptionSelected(
            option: HtmlMetadata.Option,
            messageId: MessageRenderer.Message.Identifier
        )
        case gvaButtonTapped(GvaOption)
    }

    enum Action {
        /// Actions specific for `TranscriptModel`.
        enum TranscriptAction {
            case messageCenterAvailabilityUpdated
        }
        case queue
        case connected(name: String?, imageUrl: String?)
        case transferring
        case setMessageEntryEnabled(Bool)
        case setChoiceCardInputModeEnabled(Bool)
        case setMessageText(String)
        case sendButtonHidden(Bool)
        case pickMediaButtonEnabled(Bool)
        case appendRows(Int, to: Int, animated: Bool)
        case refreshRow(Int, in: Int, animated: Bool)
        case refreshRows([Int], in: Int, animated: Bool)
        case refreshSection(Int, animated: Bool = false)
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
        case setAttachmentButtonVisibility(MediaPickerButtonVisibility)
        case fileUploadListPropsUpdated(SecureConversations.FileUploadListView.Props)
        case quickReplyPropsUpdated(QuickReplyView.Props)
        case transcript(TranscriptAction)
        case showSnackBarView
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
    }

    enum StartAction {
        case startEngagement
        case none
    }

    enum ChatType {
        case secureTranscript
        case authenticated
        case nonAuthenticated
    }
}
