import UIKit

extension UIKitBased.UIImage {
    static let live = Self(imageWithContentsOfFileAtPath: UIKit.UIImage.init(contentsOfFile:))
}

extension UIKitBased.UIApplication {
    static let live = Self(
        open: { UIApplication.shared.open($0) },
        canOpenURL: UIApplication.shared.canOpenURL,
        preferredContentSizeCategory: { UIApplication.shared.preferredContentSizeCategory }
    )
}
