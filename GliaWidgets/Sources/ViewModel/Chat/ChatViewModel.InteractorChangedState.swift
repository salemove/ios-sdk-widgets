import Foundation

extension ChatViewModel {
    func handleInteractorStateChanged(_ interactorState: InteractorState) {
        switch interactorState {
        case .none, .enqueueing, .enqueued:
            break
        case .engaged:
            environment.log.prefixed(Self.self).info("New engagement loaded")
            // Engaged state for non-transferred SC engagement when
            // ChatType is `.secureTranscript(upgradedFromChat: true)` means
            // that SC QueueTicket is accepted by operator. In this case we need to
            // switch ChatType to authenticated. For better reliability `isAuthenticated` check was added.
            if interactor.currentEngagement?.isTransferredSecureConversation == false,
               case .secureTranscript(let upgradedFromChat) = chatType,
               upgradedFromChat == true {
                let chatType: ChatType = environment.isAuthenticated() ? .authenticated : .nonAuthenticated
                setChatType(chatType)
                action?(.refreshAll)
            }

        case .ended(.byOperator):
            func handleOperatorEndedEngagement() {
                engagementAction?(.showAlert(.operatorEndedEngagement(action: { [weak self] in
                    self?.endSession()
                })))
            }

            // When operator ends engagement, `endedEngagement` supposed to be
            // present. However if this is not the case, we fallback to presenting
            // ended engagement dialog.
            guard let endedEngagement = interactor.endedEngagement else {
                handleOperatorEndedEngagement()
                return
            }

            switch endedEngagement.actionOnEnd {
            case .showSurvey:
                endSession()
            case .retain:
                delegate?(.liveChatEngagementUpgradedToSecureMessaging(self))
            case .showEndedNotification:
                handleOperatorEndedEngagement()
            case let .unknown(unhandledCase):
                environment.log.warning("Engagement ended with unknown case '\(unhandledCase)'.")
                handleOperatorEndedEngagement()
            @unknown default:
                environment.log.warning("Engagement ended with unknown case.")
                handleOperatorEndedEngagement()
            }
        // There's no need for nilling-out operator image in the bubble via
        // `engagementDelegate?(.engaged(operatorImageUrl: nil))` because bubble no
        // longer stays on integrator's screen when engagement is ended (this behaviour
        // was aligned with Android).
        case .ended:
            break
        }
    }
}
