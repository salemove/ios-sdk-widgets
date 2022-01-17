import SalemoveSDK

enum Alert {
    // Engagement
    case leaveQueueAlert(confirmed: (() -> Void))
    case endEngagementAlert(confirmed: (() -> Void))
    case operatorEndedEngagement
    // Media Upgrade
    case mediaUpgradeAlert(offer: MediaUpgradeOffer,
                           answer: AnswerWithSuccessBlock,
                           operatorName: String)
    case mediaSourceError
    // Screen Sharing
    case endScreenShareAlert(confirmed: (() -> Void))
    case startScreenShareAlert(answer: AnswerBlock,
                               operatorName: String)
    // Settings
    case cameraSettings
    case microphoneSettings
    // Error
    case operatorsUnavailable
    case unexpectedError
    case apiError
}
