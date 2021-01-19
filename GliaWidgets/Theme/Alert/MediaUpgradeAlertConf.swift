public struct MediaUpgradeAlertConf {
    public var title: String
    public var audioUpgradeAction: MediaUpgradeActionStyle
    public var phoneUpgradeAction: MediaUpgradeActionStyle

    func withOperatorName(_ name: String?) -> MediaUpgradeAlertConf {
        return MediaUpgradeAlertConf(title: title.withOperatorName(name),
                                     audioUpgradeAction: audioUpgradeAction,
                                     phoneUpgradeAction: phoneUpgradeAction)
    }
}
