public struct MultipleMediaUpgradeAlertConfiguration {
    public var title: String
    public var audioUpgradeAction: MediaUpgradeActionStyle
    public var phoneUpgradeAction: MediaUpgradeActionStyle
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
