#if DEBUG
import UIKit

extension UIKitBased.UIImage {
    static let mock = Self(
        imageWithContentsOfFileAtPath: { _ in nil }
    )
}

extension UIKitBased.UIApplication {
    static let mock = Self(
        open: { _ in },
        canOpenURL: { _ in false },
        preferredContentSizeCategory: { .unspecified },
        isIdleTimerDisabled: { _ in },
        windows: { .init() },
        connectionScenes: { .init() }
    )
}

extension UIImage {
    static let mock = UIImage(
        named: "mock-image",
        in: BundleManaging.live.current(),
        compatibleWith: nil
    ).unsafelyUnwrapped
}

extension UIKitBased.UIDevice {
    static let mock = Self.init(
        proximityState: { .init() },
        isProximityMonitoringEnabled: { _ in },
        orientationDidChangeNotification: { .init("") }
    )
}

extension UIKitBased.UIScreen {
    static let mock = Self.init(
        bounds: { UIScreen.main.bounds },
        scale: { .init() }
    )
}

extension UIKitBased.UIWindow {
    static func mock(rootViewController: UIKit.UIViewController = . init()) -> UIKitBased.UIWindow {
        let window = UIKit.UIWindow()
        window.rootViewController = rootViewController
        return window
    }
}
#endif
