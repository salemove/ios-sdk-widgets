import UIKit

public struct AudioUpgradeAlertConfiguration {
    public var title: String
    public var titleImage: UIImage?
    public var decline: String
    public var accept: String

    func withOperatorName(_ name: String?) -> AudioUpgradeAlertConfiguration {
        return AudioUpgradeAlertConfiguration(title: title.withOperatorName(name),
                                     titleImage: titleImage,
                                     decline: decline,
                                     accept: accept)
    }
}
