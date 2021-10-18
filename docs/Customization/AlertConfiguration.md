
[order]: # (7)
# AlertConfiguration

`alert: AlertConfiguration` is a property of `Theme` that is responsible for the content of alerts that appear in GliaWidgets, such as media upgrade, error messages or screen sharing offer. It allows to customize the title, icon, message and button labels (if present) of each specific alert.

`AlertConfiguration` consists of several properties of different types:
- `ConfirmationAlertConfiguration`: "Leave queue", "End engagement", "End screen share" confirmation alerts.
- `MessageAlertConfiguration`: "Operator is unavailable", "Media source unavailable", "Unexpected error", "API error" message alerts.
- `SingleMediaUpgradeAlertConfiguration`: "Upgrade to audio", "Upgrade to one-way video", "Upgrade to two-way video" offer alerts.
- `MultipleMediaUpgradeAlertConfiguration`: media upgrade (call or phone) offer alert.
- `ScreenShareOfferAlertConfiguration`: "Allow screen share" offer alert.
- `SettingsAlertConfiguration`: camera/microphone permission issue alert.

There is a default chat configuration in GliaWidgets. It means that all of the alerts' configuration properties have default values. For example, `endEngagement.title` is "End engagement?", `screenShareOffer.message` is "{operatorName} would like to see the screen of your device" and `leaveQueue.negativeTitle` is "No".

It can be created with the following initializer:
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

It can then be assigned to the `alertConfiguration` property of the `Theme`:
```swift
let theme = Theme()

theme.alertConfiguration = alertConfiguration
```

A more in-depth description of each individual property of the `AlertConfiguration` can be found in the documentation comments in Xcode itself.

It is also possible to customize individual components directly, without creating an entire `AlertConfiguration` or `Theme` yourself. This can be achieved by calling an empty initializer for `Theme` and changing its properties directly:
```swift
let theme = Theme() // create a default Theme

theme.alertConfiguration.leaveQueue.title = "Leave?"
theme.alertConfiguration.screenShareOffer.titleImage = UIImage(named:"screen")
```

Below is the default configuration of the audio upgrade alert in the chat initiated from the Glia Hub:

<p align="center">
  <img width="500" src="./images/alert_general_look.png">
</p>
