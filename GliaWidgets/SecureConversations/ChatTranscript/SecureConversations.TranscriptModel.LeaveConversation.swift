import Foundation

extension SecureConversations.TranscriptModel {
    func showLeaveConversationDialogIfNeeded() {
        if environment.shouldShowLeaveSecureConversationDialog {
            engagementAction?(.showAlert(.leaveCurrentConversation { [weak self] in
                self?.environment.leaveCurrentSecureConversation()
            }))
        }
    }
}
