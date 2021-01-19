public struct AlertConf {
    public var leaveQueue: ConfirmationAlertConf
    public var endEngagement: ConfirmationAlertConf
    public var operatorsUnavailable: MessageAlertConf
    public var upgradeMedia: TitleAlertConf
    public var unexpectedError: MessageAlertConf
    public var apiError: MessageAlertConf

    public init(leaveQueue: ConfirmationAlertConf,
                endEngagement: ConfirmationAlertConf,
                operatorsUnavailable: MessageAlertConf,
                upgradeMedia: TitleAlertConf,
                unexpectedError: MessageAlertConf,
                apiError: MessageAlertConf) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.upgradeMedia = upgradeMedia
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
