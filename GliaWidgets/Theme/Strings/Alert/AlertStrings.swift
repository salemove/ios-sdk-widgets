public struct AlertStrings {
    public var leaveQueue: AlertConfirmationStrings
    public var endEngagement: AlertConfirmationStrings
    public var operatorsUnavailable: AlertMessageStrings
    public var upgradeMedia: AlertTitleStrings
    public var unexpectedError: AlertMessageStrings
    public var apiError: AlertMessageStrings

    public init(leaveQueue: AlertConfirmationStrings,
                endEngagement: AlertConfirmationStrings,
                operatorsUnavailable: AlertMessageStrings,
                upgradeMedia: AlertTitleStrings,
                unexpectedError: AlertMessageStrings,
                apiError: AlertMessageStrings) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.upgradeMedia = upgradeMedia
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
