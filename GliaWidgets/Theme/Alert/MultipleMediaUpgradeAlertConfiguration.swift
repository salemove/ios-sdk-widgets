/// Configuration of a media upgrade confirmation alert.
public struct MultipleMediaUpgradeAlertConfiguration {
    /// Title of the alert.
    public var title: String

    /// Style of audio upgrade action.
    public var audioUpgradeAction: MediaUpgradeActionStyle

    /// Style of  phone upgrade action.
    public var phoneUpgradeAction: MediaUpgradeActionStyle

    /// Controls the appearance of the "Powered by" text and logo in the alert.
    public var showsPoweredBy: Bool

    func withOperatorName(_ name: String?) -> MultipleMediaUpgradeAlertConfiguration {
        return MultipleMediaUpgradeAlertConfiguration(
            title: title.withOperatorName(name),
            audioUpgradeAction: audioUpgradeAction,
            phoneUpgradeAction: phoneUpgradeAction,
            showsPoweredBy: showsPoweredBy
        )
    }
}
