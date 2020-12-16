public struct AlertStrings {
    public var leaveQueue: AlertConfirmationStrings
    public var endEngagement: AlertConfirmationStrings
    public var operatorsUnavailable: AlertMessageStrings
    public var unexpectedError: AlertMessageStrings
    public var apiError: AlertMessageStrings

    public init(leaveQueue: AlertConfirmationStrings,
                endEngagement: AlertConfirmationStrings,
                operatorsUnavailable: AlertMessageStrings,
                unexpectedError: AlertMessageStrings,
                apiError: AlertMessageStrings) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
