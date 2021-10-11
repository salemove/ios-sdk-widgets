/// Configurations for alerts and confirmations.
public struct AlertConfiguration {
    /// Configuration of the queue leaving confirmation alert.
    public var leaveQueue: ConfirmationAlertConfiguration

    /// Configuration of the engagement ending confirmation alert.
    public var endEngagement: ConfirmationAlertConfiguration

    /// Configuration of the operator ending engagement.
    public var operatorEndedEngagement: SingleActionAlertConfiguration

    /// Configuration of the operator's unavailable alert.
    public var operatorsUnavailable: MessageAlertConfiguration

    /// Configuration of the media upgrade confirmation alert.
    public var mediaUpgrade: MultipleMediaUpgradeAlertConfiguration

    /// Configuration of the audio upgrade confirmation alert.
    public var audioUpgrade: SingleMediaUpgradeAlertConfiguration

    /// Configuration of the one-way video upgrade confirmation alert.
    public var oneWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration

    /// Configuration of the two-way video upgrade confirmation alert.
    public var twoWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration

    /// Configuration of the screen sharing start confirmation alert.
    public var screenShareOffer: ScreenShareOfferAlertConfiguration

    /// Configuration of the screen sharing end confirmation alert.
    public var endScreenShare: ConfirmationAlertConfiguration

    /// Configuration of the microphone permission settings alert.
    public var microphoneSettings: SettingsAlertConfiguration

    /// Configuration of the camera permission settings alert.
    public var cameraSettings: SettingsAlertConfiguration

    /// Configuration of the unavailable media source (camera, etc) alert.
    public var mediaSourceNotAvailable: MessageAlertConfiguration

    /// Configuration of the unexpected error alert.
    public var unexpectedError: MessageAlertConfiguration

    /// Configuration of the API error alert.
    public var apiError: MessageAlertConfiguration

    ///
    /// - Parameters:
    ///   - leaveQueue: Configuration of the queue leaving confirmation alert.
    ///   - endEngagement: Configuration of the engagement ending confirmation alert.
    ///   - operatorEndedEngagement: Configuration of the operator ending engagement
    ///   - operatorsUnavailable: Configuration of the operator's unavailable alert.
    ///   - mediaUpgrade: Configuration of the media upgrade confirmation alert.
    ///   - audioUpgrade: Configuration of the audio upgrade confirmation alert.
    ///   - oneWayVideoUpgrade: Configuration of the one-way video upgrade confirmation alert.
    ///   - twoWayVideoUpgrade: Configuration of the two-way video upgrade confirmation alert.
    ///   - screenShareOffer: Configuration of the screen sharing start confirmation alert.
    ///   - endScreenShare: Configuration of the screen sharing end confirmation alert.
    ///   - microphoneSettings: Configuration of the microphone permission settings alert.
    ///   - cameraSettings: Configuration of the camera permission settings alert.
    ///   - mediaSourceNotAvailable: Configuration of the unavailable media source (camera, etc) alert.
    ///   - unexpectedError: Configuration of the unexpected error alert.
    ///   - apiError: Configuration of the API error alert.
    ///
    public init(
        leaveQueue: ConfirmationAlertConfiguration,
        endEngagement: ConfirmationAlertConfiguration,
        operatorEndedEngagement: SingleActionAlertConfiguration,
        operatorsUnavailable: MessageAlertConfiguration,
        mediaUpgrade: MultipleMediaUpgradeAlertConfiguration,
        audioUpgrade: SingleMediaUpgradeAlertConfiguration,
        oneWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration,
        twoWayVideoUpgrade: SingleMediaUpgradeAlertConfiguration,
        screenShareOffer: ScreenShareOfferAlertConfiguration,
        endScreenShare: ConfirmationAlertConfiguration,
        microphoneSettings: SettingsAlertConfiguration,
        cameraSettings: SettingsAlertConfiguration,
        mediaSourceNotAvailable: MessageAlertConfiguration,
        unexpectedError: MessageAlertConfiguration,
        apiError: MessageAlertConfiguration
    ) {
        self.leaveQueue = leaveQueue
        self.endEngagement = endEngagement
        self.operatorEndedEngagement = operatorEndedEngagement
        self.operatorsUnavailable = operatorsUnavailable
        self.mediaUpgrade = mediaUpgrade
        self.audioUpgrade = audioUpgrade
        self.oneWayVideoUpgrade = oneWayVideoUpgrade
        self.twoWayVideoUpgrade = twoWayVideoUpgrade
        self.screenShareOffer = screenShareOffer
        self.endScreenShare = endScreenShare
        self.microphoneSettings = microphoneSettings
        self.cameraSettings = cameraSettings
        self.mediaSourceNotAvailable = mediaSourceNotAvailable
        self.unexpectedError = unexpectedError
        self.apiError = apiError
    }
}
