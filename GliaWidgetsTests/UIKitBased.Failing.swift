@testable import GliaWidgets

extension UIKitBased.UIImage {
    static let failing = Self(
        imageWithContentsOfFileAtPath: { _ in
            fail("\(Self.self).imageWithContentsOfFileAtPath")
            return nil
        }
    )
}

extension UIKitBased.UIApplication {
    /// `EngagementCoordinator.init` reads connected scenes unconditionally to
    /// resolve the layout mode, so environments that build a coordinator can't
    /// let this one fail loudly (same reasoning as `resolveLayoutMode`).
    static var failingWithNoConnectedScenes: Self {
        var application = Self.failing
        application.connectionScenes = { [] }
        return application
    }

    static let failing = Self(
        open: { _ in
            fail("\(Self.self).open")
        },
        canOpenURL: { _ in
            fail("\(Self.self).canOpenURL")
            return false
        },
        preferredContentSizeCategory: {
            fail("\(Self.self).preferredContentSizeCategory")
            return .unspecified
        },
        isIdleTimerDisabled: { _ in
            fail("\(Self.self).isIdleTimerDisabled")
        },
        windows: {
            fail("\(Self.self).windows")
            return []
        },
        connectionScenes: {
            fail("\(Self.self).connectionScenes")
            return .init()
        },
        applicationState: {
            fail("\(Self.self).applicationState")
            return .inactive
        }
    )
}

extension UIKitBased.UIScreen {
    static let failing = Self(
        bounds: {
            fail("\(Self.self).bounds")
            return CGRect()
        },
        scale: {
            fail("\(Self.self).scale")
            return 0.0
        }
    )
}

extension UIKitBased.UIDevice {
    static let failing = Self(
        proximityState: {
            fail("\(Self.self).proximityState")
            return false
        },
        isProximityMonitoringEnabled: { _ in
            fail("\(Self.self).isProximityMonitoringEnabled")
        },
        orientationDidChangeNotification: {
            fail("\(Self.self).orientationDidChangeNotification")
            return NSNotification.Name(rawValue: "")
        },
        orientation: {
            fail("\(Self.self).orientation")
            return .unknown
        }
    )
}
