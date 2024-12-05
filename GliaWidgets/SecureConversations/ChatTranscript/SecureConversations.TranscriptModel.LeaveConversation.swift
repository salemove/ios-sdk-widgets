import Foundation

extension SecureConversations.TranscriptModel {
    func showLeaveConversationDialogIfNeeded() {
        if environment.shouldShowLeaveSecureConversationDialog {
            let action = EngagementViewModel.Action.showAlert(
                .leaveCurrentConversation(
                    confirmed: { [weak self] in
                        self?.environment.leaveCurrentSecureConversation()
                    }, declined: { [weak self] in
                        guard let self else {
                            return
                        }
                        self.markMessagesAsRead(with: self.hasUnreadMessages)
                    }
                )
            )
            engagementAction?(action)
        }
    }
}
