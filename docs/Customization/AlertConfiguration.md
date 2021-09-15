
[order]: # (7)
# AlertConfiguration

`alert: AlertConfiguration` is a property of `Theme` that is responsible for specific UI elements of alerts that appear in GliaWidgets, such as media upgrade or screen sharing offer. It allows to customize the title, message and button labels (if present) of each specific alert.

`AlertConfiguration` consists of several properties of different types:
- `ConfirmationAlertConfiguration`: "Leave queue", "End engagement", "End screen share" confirmation alerts.
- `MessageAlertConfiguration`: "Operator is unavailable", "Media source unavailable", "Unexpected error", "API error" message alerts.
- `SingleMediaUpgradeAlertConfiguration`: "Upgrade to audio", "Upgrade to one-way video", "Upgrade to two-way video" offer alerts.
- `MultipleMediaUpgradeAlertConfiguration`: media upgrade (call or phone) offer alert.
- `ScreenShareOfferAlertConfiguration`: "Allow screen share" offer alert.
- `SettingsAlertConfiguration`: camera/microphone permission issue alert.

It can be created via the following initializer and assigned to `alertConfiguration` property of `Theme`:
```swift
let alertConfiguration = AlertConfiguration(
    leaveQueue: ConfirmationAlertConfiguration,
    endEngagement: ConfirmationAlertConfiguration,
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
)
```
