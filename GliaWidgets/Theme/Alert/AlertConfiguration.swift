public struct AlertConfiguration {
    public var leaveQueue: ConfirmationAlertConfiguration
    public var endEngagement: ConfirmationAlertConfiguration
    public var operatorsUnavailable: MessageAlertConfiguration
    public var mediaUpgrade: MultipleMediaUpgradeAlertConfiguration
    public var audioUpgrade: SingleMediaUpgradeAlertConfiguration
    public var videoUpgrade: SingleMediaUpgradeAlertConfiguration
    public var microphoneSettings: SettingsAlertConfiguration
    public var unexpectedError: MessageAlertConfiguration
    public var apiError: MessageAlertConfiguration

    public init(leaveQueue: ConfirmationAlertConfiguration,
                endEngagement: ConfirmationAlertConfiguration,
                operatorsUnavailable: MessageAlertConfiguration,
                mediaUpgrade: MultipleMediaUpgradeAlertConfiguration,
                audioUpgrade: SingleMediaUpgradeAlertConfiguration,
                videoUpgrade: SingleMediaUpgradeAlertConfiguration,
                microphoneSettings: SettingsAlertConfiguration,
                unexpectedError: MessageAlertConfiguration,
                apiError: MessageAlertConfiguration) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.mediaUpgrade = mediaUpgrade
        self.audioUpgrade = audioUpgrade
        self.videoUpgrade = videoUpgrade
        self.microphoneSettings = microphoneSettings
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
