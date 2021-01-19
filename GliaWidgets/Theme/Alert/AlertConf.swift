public struct AlertConf {
    public var leaveQueue: ConfirmationAlertConf
    public var endEngagement: ConfirmationAlertConf
    public var operatorsUnavailable: MessageAlertConf
    public var mediaUpgrade: MediaUpgradeAlertConf
    public var unexpectedError: MessageAlertConf
    public var apiError: MessageAlertConf

    public init(leaveQueue: ConfirmationAlertConf,
                endEngagement: ConfirmationAlertConf,
                operatorsUnavailable: MessageAlertConf,
                mediaUpgrade: MediaUpgradeAlertConf,
                unexpectedError: MessageAlertConf,
                apiError: MessageAlertConf) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.mediaUpgrade = mediaUpgrade
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
