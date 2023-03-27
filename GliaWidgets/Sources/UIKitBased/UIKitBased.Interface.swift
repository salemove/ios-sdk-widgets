import UIKit

enum UIKitBased {
    struct UIImage {
        var imageWithContentsOfFileAtPath: (String) -> UIKit.UIImage?
    }

    struct UIApplication {
        var open: (URL) -> Void
        var canOpenURL: (URL) -> Bool
        var preferredContentSizeCategory: () -> UIContentSizeCategory
        var isIdleTimerDisabled: (Bool) -> Void
        var windows: () -> [UIKit.UIWindow]
    }

    struct UIDevice {
        var proximityState: () -> Bool
        var isProximityMonitoringEnabled: (Bool) -> Void
    }

    struct UIScreen {
        var brightness: () -> CGFloat
        var setBrightness: (CGFloat) -> Void
    }
}
