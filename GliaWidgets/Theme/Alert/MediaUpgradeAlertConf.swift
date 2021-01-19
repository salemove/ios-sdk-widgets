public struct MediaUpgradeAlertConf {
    public var title: String
    public var audioUpgradeAction: MediaUpgradeActionStyle
    public var phoneUpgradeAction: MediaUpgradeActionStyle

    private static let kOperatorNamePlaceholder = "{operatorName}"

    public init(title: String,
                audioUpgradeAction: MediaUpgradeActionStyle,
                phoneUpgradeAction: MediaUpgradeActionStyle) {
        self.title = title
        self.audioUpgradeAction = audioUpgradeAction
        self.phoneUpgradeAction = phoneUpgradeAction
    }

    func withOperatorName(_ name: String?) -> MediaUpgradeAlertConf {
        let name = name ?? L10n.operator
        let title = self.title.replacingOccurrences(of: MediaUpgradeAlertConf.kOperatorNamePlaceholder,
                                                    with: name)
        return MediaUpgradeAlertConf(title: title,
                                     audioUpgradeAction: audioUpgradeAction,
                                     phoneUpgradeAction: phoneUpgradeAction)
    }
}
