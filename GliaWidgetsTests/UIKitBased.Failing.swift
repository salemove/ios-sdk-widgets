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
            fail("\(Self.self).window")
            return []
        },
        statusBarOrientation: {
            fail("\(Self.self).statusBarOrientation")
            return .portrait
        }
    )
}

extension UIKitBased.UIScreen {
    static let failing = Self(
        brightness: {
            fail("\(Self.self).brightness")
            return 0.0
        },
        setBrightness: { _ in
            fail("\(Self.self).setBrightness")
            return
        },
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
        }
    )
}
