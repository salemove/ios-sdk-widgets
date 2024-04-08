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
        var connectionScenes: () -> Set<UIScene>
    }

    struct UIDevice {
        var proximityState: () -> Bool
        var isProximityMonitoringEnabled: (Bool) -> Void
        var orientationDidChangeNotification: () -> NSNotification.Name
    }

    struct UIScreen {
        var bounds: () -> CGRect
        var scale: () -> CGFloat
    }

    typealias UIWindow = UIKit.UIWindow
}

extension UIKitBased.UIApplication: Transformable {}
