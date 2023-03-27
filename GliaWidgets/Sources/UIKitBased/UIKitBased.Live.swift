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
        windows: { UIApplication.shared.windows }
    )
}

extension UIKitBased.UIDevice {
    static let live = Self.init(
        proximityState: { UIDevice.current.proximityState },
        isProximityMonitoringEnabled: { UIDevice.current.isProximityMonitoringEnabled = $0 }
    )
}

extension UIKitBased.UIScreen {
    static let live = Self.init(
        brightness: { UIScreen.main.brightness },
        setBrightness: { UIScreen.main.brightness = $0 }
    )
}
