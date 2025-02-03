import Foundation

extension SecureConversations.TranscriptModel {
    func showLeaveConversationDialogIfNeeded() {
        func handleInteractorState() {
            switch environment.interactor.state {
                // If engagement has been started
                // we signal perform upgrade.
            case .engaged:
                delegate?(.upgradeToChatEngagement(self))
            case .none, .enqueueing, .ended, .enqueued:
                environment.interactor.addObserver(self) { [weak self] event in
                    self?.handleInteractorEvent(event)
                }
            }
        }
        guard environment.shouldShowLeaveSecureConversationDialog() else {
            handleInteractorState()
            return
        }
        let action = EngagementViewModel.Action.showAlert(
            .leaveCurrentConversation(
                confirmed: { [weak self] in
                    self?.environment.leaveCurrentSecureConversation(true)
                }, declined: { [weak self] in
                    guard let self else { return }
                    environment.leaveCurrentSecureConversation(false)
                    handleInteractorState()
                    markMessagesAsRead(with: self.hasUnreadMessages)
                }
            )
        )
        engagementAction?(action)
    }
}
