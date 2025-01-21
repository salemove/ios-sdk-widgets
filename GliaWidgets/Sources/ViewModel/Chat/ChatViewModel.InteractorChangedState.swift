import Foundation

extension ChatViewModel {
    func handleInteractorStateChanged(_ interactorState: InteractorState) {
        switch interactorState {
        case .none, .enqueueing, .enqueued:
            break
        case .engaged:
            environment.log.prefixed(Self.self).info("New engagement loaded")
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
            // TODO: review '.retain' case in context of SC 2 transfer MOB-3978.
            case .retain, .showEndedNotification:
                handleOperatorEndedEngagement()
            case let .unknown(unhandledCase):
                // TODO: log unhandled case MOB-3971
                handleOperatorEndedEngagement()
            @unknown default:
                // TODO: log unhandled case MOB-3971
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
