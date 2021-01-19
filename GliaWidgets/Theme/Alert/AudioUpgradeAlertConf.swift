import UIKit

public struct AudioUpgradeAlertConf {
    public var title: String
    public var titleImage: UIImage?
    public var decline: String
    public var accept: String

    func withOperatorName(_ name: String?) -> AudioUpgradeAlertConf {
        return AudioUpgradeAlertConf(title: title.withOperatorName(name),
                                     titleImage: titleImage,
                                     decline: decline,
                                     accept: accept)
    }
}
