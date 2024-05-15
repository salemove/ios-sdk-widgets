import Foundation

extension FlipCameraButtonStyle {
    /// Accessibility properties for `FlipCameraButtonStyle`.
    public struct Accessibility: Equatable {
        /// Accessibility label for switching to back camera.
        public var switchToBackCameraAccessibilityLabel: String
        /// Accessibility hint for switching to back camera.
        public var switchToBackCameraAccessibilityHint: String
        /// Accessibility label for switching to front camera.
        public var switchToFrontCameraAccessibilityLabel: String
        /// Accessibility hint for switching to front camera.
        public var switchToFrontCameraAccessibilityHint: String

        /// - Parameters:
        ///   - switchToBackCameraAccessibilityLabel: Accessibility label for switching to back camera.
        ///   - switchToBackCameraAccessibilityHint: Accessibility hint for switching to back camera.
        ///   - switchToFrontCameraAccessibilityLabel: Accessibility label for switching to front camera.
        ///   - switchToFrontCameraAccessibilityHint: Accessibility hint for switching to front camera.
        public init(
            switchToBackCameraAccessibilityLabel: String,
            switchToBackCameraAccessibilityHint: String,
            switchToFrontCameraAccessibilityLabel: String,
            switchToFrontCameraAccessibilityHint: String
        ) {
            self.switchToBackCameraAccessibilityLabel = switchToBackCameraAccessibilityLabel
            self.switchToBackCameraAccessibilityHint = switchToBackCameraAccessibilityHint
            self.switchToFrontCameraAccessibilityLabel = switchToFrontCameraAccessibilityLabel
            self.switchToFrontCameraAccessibilityHint = switchToFrontCameraAccessibilityHint
        }
    }
}

extension FlipCameraButtonStyle.Accessibility {
    /// Accessibility is not supported intentionally.
    public static let unsupported = Self(
        switchToBackCameraAccessibilityLabel: "",
        switchToBackCameraAccessibilityHint: "",
        switchToFrontCameraAccessibilityLabel: "",
        switchToFrontCameraAccessibilityHint: ""
    )
}

extension FlipCameraButtonStyle.Accessibility {
    static let nop = Self(
        switchToBackCameraAccessibilityLabel: "",
        switchToBackCameraAccessibilityHint: "",
        switchToFrontCameraAccessibilityLabel: "",
        switchToFrontCameraAccessibilityHint: ""
    )
}

extension FlipCameraButtonStyle.Accessibility {
    func flipCameraButtonPropsAccessibility(for facing: CoreSdkClient.CameraDevice.Facing) -> FlipCameraButton.Props.Accessibility {
        switch facing {
        case .front:
            return .init(
                accessibilityLabel: self.switchToBackCameraAccessibilityLabel,
                accessibilityHint: self.switchToBackCameraAccessibilityHint
            )
        case .back:
            return .init(
                accessibilityLabel: self.switchToFrontCameraAccessibilityLabel,
                accessibilityHint: self.switchToFrontCameraAccessibilityHint
            )
        case .unspecified:
            return .nop
        @unknown default:
            return .nop
        }
    }
}
