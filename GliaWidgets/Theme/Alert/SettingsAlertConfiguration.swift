/// Configuration of an alert that offers to go to app's settings in the Settings app.
public struct SettingsAlertConfiguration {
    /// Title of the alert.
    public var title: String

    /// Message of the alert.
    public var message: String

    /// Title of the settings action button.
    public var settingsTitle: String?

    /// Title of the cancel action button.
    public var cancelTitle: String?
}
