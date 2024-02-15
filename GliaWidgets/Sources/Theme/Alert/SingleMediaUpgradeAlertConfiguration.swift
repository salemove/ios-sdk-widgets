import UIKit

/// Configuration of the media upgrade confirmation alert.
public struct SingleMediaUpgradeAlertConfiguration {
    /// Title of the alert.
    public var title: String

    /// Image to show in the title.
    public var titleImage: UIImage?

    /// Text of the decline action button.
    public var decline: String

    /// Text of the accept action button.
    public var accept: String

    /// Controls the appearance of the "Powered by" text and logo in the alert.
    public var showsPoweredBy: Bool
}

extension SingleMediaUpgradeAlertConfiguration {
    func withOperatorName(_ name: String?) -> SingleMediaUpgradeAlertConfiguration {
        return SingleMediaUpgradeAlertConfiguration(
            title: title.withOperatorName(name),
            titleImage: titleImage,
            decline: decline,
            accept: accept,
            showsPoweredBy: showsPoweredBy
        )
    }
}
