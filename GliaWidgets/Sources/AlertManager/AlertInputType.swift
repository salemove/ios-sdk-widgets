import Foundation

enum AlertInputType: Equatable {
    case error(
        error: (any Error)?,
        dismissed: (() -> Void)? = nil
    )
    case cameraSettings(dismissed: (() -> Void)? = nil)
    case endEngagement(confirmed: () -> Void)
    case endScreenShare(confirmed: () -> Void)
    case leaveQueue(confirmed: () -> Void)
    case liveObservationConfirmation(
        link: (WebViewController.Link) -> Void,
        accepted: () -> Void,
        declined: () -> Void
    )
    case mediaSourceNotAvailable(dismissed: (() -> Void)? = nil)
    case microphoneSettings(dismissed: (() -> Void)? = nil)
    case operatorEndedEngagement(action: () -> Void)
    case unsupportedGvaBroadcastError(dismissed: (() -> Void)? = nil)
    case unavailableMessageCenter(dismissed: (() -> Void)? = nil)
    case unavailableMessageCenterForBeingUnauthenticated(dismissed: (() -> Void)? = nil)
    case mediaUpgrade(
        operators: String,
        offer: CoreSdkClient.MediaUpgradeOffer,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: CoreSdkClient.AnswerWithSuccessBlock
    )
    case screenSharing(
        operators: String,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: CoreSdkClient.AnswerBlock
    )
    case leaveCurrentConversation(confirmed: () -> Void, declined: (() -> Void)? = nil)
    case requestPushNoticationsPermissions(confirmed: () -> Void, declined: () -> Void)

    static func == (lhs: AlertInputType, rhs: AlertInputType) -> Bool {
        switch (lhs, rhs) {
        case (.cameraSettings, .cameraSettings):
            return true
        case (.endEngagement, .endEngagement):
            return true
        case (.endScreenShare, .endScreenShare):
            return true
        case (.leaveQueue, .leaveQueue):
            return true
        case (.liveObservationConfirmation, .liveObservationConfirmation):
            return true
        case (.mediaSourceNotAvailable, .mediaSourceNotAvailable):
            return true
        case (.microphoneSettings, .microphoneSettings):
            return true
        case (.operatorEndedEngagement, .operatorEndedEngagement):
            // temporarily considered as unequal to fix presenting `operatorEndedEngagement` alert
            return false
        case (.unsupportedGvaBroadcastError, .unsupportedGvaBroadcastError):
            return true
        case (.unavailableMessageCenter, .unavailableMessageCenter):
            return false
        case (.unavailableMessageCenterForBeingUnauthenticated, .unavailableMessageCenterForBeingUnauthenticated):
            return false
        case (.mediaUpgrade, .mediaUpgrade):
            return false
        case (.screenSharing, .screenSharing):
            return false
        case let (.error(lhsError, _), .error(rhsError, _)):
            return (lhsError as NSError?) == (rhsError as NSError?)
        case (.leaveCurrentConversation, .leaveCurrentConversation):
            return true
        case (.requestPushNoticationsPermissions, .requestPushNoticationsPermissions):
            return true
        default:
            return false
        }
    }
}
