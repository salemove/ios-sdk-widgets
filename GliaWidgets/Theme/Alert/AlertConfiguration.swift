public struct AlertConfiguration {
    public var leaveQueue: ConfirmationAlertConfiguration
    public var endEngagement: ConfirmationAlertConfiguration
    public var operatorsUnavailable: MessageAlertConfiguration
    public var mediaUpgrade: MultipleMediaUpgradeAlertConfiguration
    public var audioUpgrade: SingleMediaUpgradeAlertConfiguration
    public var oneWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration
    public var twoWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration
    public var microphoneSettings: SettingsAlertConfiguration
    public var cameraSettings: SettingsAlertConfiguration
    public var unexpectedError: MessageAlertConfiguration
    public var apiError: MessageAlertConfiguration

    public init(leaveQueue: ConfirmationAlertConfiguration,
                endEngagement: ConfirmationAlertConfiguration,
                operatorsUnavailable: MessageAlertConfiguration,
                mediaUpgrade: MultipleMediaUpgradeAlertConfiguration,
                audioUpgrade: SingleMediaUpgradeAlertConfiguration,
                oneWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration,
                twoWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration,
                microphoneSettings: SettingsAlertConfiguration,
                cameraSettings: SettingsAlertConfiguration,
                unexpectedError: MessageAlertConfiguration,
                apiError: MessageAlertConfiguration) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.mediaUpgrade = mediaUpgrade
        self.audioUpgrade = audioUpgrade
        self.oneWayVideoUpgrade = oneWayVideoUpgrade
        self.twoWayVideoUpgrade = twoWayVideoUpgrade
        self.microphoneSettings = microphoneSettings
        self.cameraSettings = cameraSettings
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
