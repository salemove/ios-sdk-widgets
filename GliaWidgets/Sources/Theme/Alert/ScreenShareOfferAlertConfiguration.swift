import UIKit

/// Configuration of the screen sharing confirmation alert.
public struct ScreenShareOfferAlertConfiguration {
    /// Title of the alert.
    public var title: String

    /// Message of the alert.
    public var message: String

    /// Image to show in the title.
    public var titleImage: UIImage?

    /// Text of the decline action button.
    public var decline: String

    /// Text of the accept action button.
    public var accept: String

    /// Controls the appearance of the "Powered by" text and logo in the alert.
    public var showsPoweredBy: Bool

    func withOperatorName(_ name: String?) -> ScreenShareOfferAlertConfiguration {
        return ScreenShareOfferAlertConfiguration(
            title: Localization.operatorName(name, on: title),
            message: Localization.operatorName(name, on: message),
            titleImage: titleImage,
            decline: decline,
            accept: accept,
            showsPoweredBy: showsPoweredBy
        )
    }
}
