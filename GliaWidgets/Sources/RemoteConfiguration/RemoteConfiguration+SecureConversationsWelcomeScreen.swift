import Foundation

extension RemoteConfiguration {
    struct SecureConversationsWelcomeScreen: Codable {
        let header: Header?
        let welcomeTitle: Text?
        let titleImage: Color?
        let welcomeSubtitle: Text?
        let checkMessagesButton: Text?
        let messageTitle: Text?
        let messageTextViewNormal: Text?
        let messageTextViewDisabled: Text?
        let messageTextViewActive: Text?
        let messageTextViewLayer: Layer?
        let enabledSendButton: Button?
        let disabledSendButton: Button?
        let loadingSendButton: Button?
        let activityIndicatorColor: Color?
        let messageWarning: Text?
        let messageWarningIconColor: Color?
        let filePickerButton: Color?
        let filePickerButtonDisabled: Color?
        let attachmentList: FileUploadBar?
        let pickMedia: AttachmentSourceList?
        let background: Color?
    }

    struct SecureConversationsConfirmationScreen: Codable {
        let background: Color?
        let checkMessagesButton: Button?
        let header: Header?
        let iconColor: Color?
        let subtitle, title: Text?
    }
}
