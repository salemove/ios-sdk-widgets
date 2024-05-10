import Foundation

/// Style for camera switching button.
public struct FlipCameraButtonStyle: Equatable {
    /// Button state that specifies colors for background and image.
    public struct State: Equatable {
        /// Button background color.
        public var backgroundColor: ColorType
        /// Button image color.
        public var imageColor: ColorType

        /// - Parameters:
        ///   - backgroundColor: Button background color.
        ///   - imageColor: Button image color.
        public init(
            backgroundColor: ColorType,
            imageColor: ColorType
        ) {
            self.backgroundColor = backgroundColor
            self.imageColor = imageColor
        }
    }

    /// Active (normal) state of the button.
    public var activeState: State
    /// Inactive (disabled) state of the button.
    public var inactiveState: State
    /// Selected (highlighted) state of the button.
    public var selectedState: State
    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - activeState: Active (normal) state of the button.
    ///   - inactiveState: Inactive (disabled) state of the button.
    ///   - selectedState: Selected (highlighted) state of the button.
    ///   - accessibility: Accessibility related properties.
    public init(
        activeState: State,
        inactiveState: State,
        selectedState: State,
        accessibility: Accessibility
    ) {
        self.activeState = activeState
        self.inactiveState = inactiveState
        self.selectedState = selectedState
        self.accessibility = accessibility
    }
}

extension FlipCameraButtonStyle {
    static let nop = Self(
        activeState: .nop,
        inactiveState: .nop,
        selectedState: .nop,
        accessibility: .nop
    )
}

extension FlipCameraButtonStyle.State {
    static let nop = Self(
        backgroundColor: .fill(color: .clear),
        imageColor: .fill(color: .clear)
    )
}

extension FlipCameraButtonStyle {
    // Used for feature development.
    // Will be removed with MOB-3292.
    static let custom = Self(
        activeState: State(
            backgroundColor: .fill(color: .init(hex: "#04728c")),
            imageColor: .fill(color: .init(hex: "#FFFFFF"))
        ),
        inactiveState: State(
            backgroundColor: .fill(color: .init(hex: "#042835")),
            imageColor: .fill(color: .init(hex: "#FFFFFF"))
        ),
        selectedState: State(
            backgroundColor: .fill(color: .init(hex: "#000000")),
            imageColor: .fill(color: .init(hex: "#FFFFFF"))
        ),
        accessibility: .nop
    )
}

extension FlipCameraButtonStyle: Transformable {}
