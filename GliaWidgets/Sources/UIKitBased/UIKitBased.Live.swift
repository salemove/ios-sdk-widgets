import UIKit

extension UIKitBased.UIImage {
    static let live = Self(imageWithContentsOfFileAtPath: UIKit.UIImage.init(contentsOfFile:))
}

extension UIKitBased.UIApplication {
    static let live = Self(
        open: { UIApplication.shared.open($0) },
        canOpenURL: UIApplication.shared.canOpenURL,
        preferredContentSizeCategory: { UIApplication.shared.preferredContentSizeCategory },
        isIdleTimerDisabled: { UIApplication.shared.isIdleTimerDisabled = $0 },
        windows: {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        },
        connectionScenes: { UIApplication.shared.connectedScenes },
        applicationState: { UIApplication.shared.applicationState }
    )
}

extension UIKitBased.UIDevice {
    static let live = Self.init(
        proximityState: { UIDevice.current.proximityState },
        isProximityMonitoringEnabled: { UIDevice.current.isProximityMonitoringEnabled = $0 },
        orientationDidChangeNotification: { UIDevice.orientationDidChangeNotification },
        orientation: { UIDevice.current.orientation }
    )
}

extension UIKitBased.UIScreen {
    static let live = Self.init(
        bounds: { UIScreen.main.bounds },
        scale: { UIScreen.main.scale }
    )
}
