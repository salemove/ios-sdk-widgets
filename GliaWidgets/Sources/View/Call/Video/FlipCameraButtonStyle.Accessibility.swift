import Foundation

extension FlipCameraButtonStyle {
    /// Accessibility properties for `FlipCameraButtonStyle`.
    public struct Accessibility: Equatable {
        /// Accessibility label for switching to back camera.
        public var switchToBackCameraAccessibilityLabel: String
        /// Accessibility label for switching to front camera.
        public var switchToFrontCameraAccessibilityLabel: String

        /// - Parameters:
        ///   - switchToBackCameraAccessibilityLabel: Accessibility label for switching to back camera.
        ///   - switchToFrontCameraAccessibilityLabel: Accessibility label for switching to front camera.
        public init(
            switchToBackCameraAccessibilityLabel: String,
            switchToFrontCameraAccessibilityLabel: String
        ) {
            self.switchToBackCameraAccessibilityLabel = switchToBackCameraAccessibilityLabel
            self.switchToFrontCameraAccessibilityLabel = switchToFrontCameraAccessibilityLabel
        }
    }
}

extension FlipCameraButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        switchToBackCameraAccessibilityLabel: "",
        switchToFrontCameraAccessibilityLabel: ""
    )
}

extension FlipCameraButtonStyle.Accessibility {
    static let nop = Self(
        switchToBackCameraAccessibilityLabel: "",
        switchToFrontCameraAccessibilityLabel: ""
    )
}

extension FlipCameraButtonStyle.Accessibility {
    func accessibilityLabel(for facing: CoreSdkClient.CameraDevice.Facing) -> String {
        switch facing {
        case .front:
            return self.switchToBackCameraAccessibilityLabel
        case .back:
            return self.switchToFrontCameraAccessibilityLabel
        case .unspecified:
            return ""
        @unknown default:
            return ""
        }
    }
}
