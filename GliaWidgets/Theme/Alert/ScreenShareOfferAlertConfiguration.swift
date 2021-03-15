import UIKit

public struct ScreenShareOfferAlertConfiguration {
    public var title: String
    public var message: String
    public var titleImage: UIImage?
    public var decline: String
    public var accept: String

    func withOperatorName(_ name: String?) -> ScreenShareOfferAlertConfiguration {
        return ScreenShareOfferAlertConfiguration(
            title: title.withOperatorName(name),
            message: message.withOperatorName(name),
            titleImage: titleImage,
            decline: decline,
            accept: accept
        )
    }
}
