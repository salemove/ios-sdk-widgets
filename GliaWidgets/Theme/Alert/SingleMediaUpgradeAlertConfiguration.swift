import UIKit

public struct SingleMediaUpgradeAlertConfiguration {
    public var title: String
    public var titleImage: UIImage?
    public var decline: String
    public var accept: String

    func withOperatorName(_ name: String?) -> SingleMediaUpgradeAlertConfiguration {
        return SingleMediaUpgradeAlertConfiguration(
            title: title.withOperatorName(name),
            titleImage: titleImage,
            decline: decline,
            accept: accept
        )
    }
}
