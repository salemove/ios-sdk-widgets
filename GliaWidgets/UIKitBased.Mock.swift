#if DEBUG
import UIKit

extension UIKitBased.UIImage {
    static let mock = Self(
        imageWithContentsOfFileAtPath: { _ in nil }
    )
}

extension UIImage {
    static let mock = UIImage(
        named: "mock-image",
        in: BundleManaging.live.current(),
        compatibleWith: nil
    ).unsafelyUnwrapped
}

#endif
