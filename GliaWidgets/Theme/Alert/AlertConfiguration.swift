public struct AlertConfiguration {
    public var leaveQueue: ConfirmationAlertConfiguration
    public var endEngagement: ConfirmationAlertConfiguration
    public var operatorsUnavailable: MessageAlertConfiguration
    public var mediaUpgrade: MediaUpgradeAlertConfiguration
    public var audioUpgrade: AudioUpgradeAlertConfiguration
    public var microphoneSettings: SettingsAlertConfiguration
    public var unexpectedError: MessageAlertConfiguration
    public var apiError: MessageAlertConfiguration

    public init(leaveQueue: ConfirmationAlertConfiguration,
                endEngagement: ConfirmationAlertConfiguration,
                operatorsUnavailable: MessageAlertConfiguration,
                mediaUpgrade: MediaUpgradeAlertConfiguration,
                audioUpgrade: AudioUpgradeAlertConfiguration,
                microphoneSettings: SettingsAlertConfiguration,
                unexpectedError: MessageAlertConfiguration,
                apiError: MessageAlertConfiguration) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.mediaUpgrade = mediaUpgrade
        self.audioUpgrade = audioUpgrade
        self.microphoneSettings = microphoneSettings
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
