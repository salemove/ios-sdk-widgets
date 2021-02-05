public struct MediaUpgradeAlertConfiguration {
    public var title: String
    public var audioUpgradeAction: MediaUpgradeActionStyle
    public var phoneUpgradeAction: MediaUpgradeActionStyle

    func withOperatorName(_ name: String?) -> MediaUpgradeAlertConfiguration {
        return MediaUpgradeAlertConfiguration(title: title.withOperatorName(name),
                                     audioUpgradeAction: audioUpgradeAction,
                                     phoneUpgradeAction: phoneUpgradeAction)
    }
}
