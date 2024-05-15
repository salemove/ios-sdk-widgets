import UIKit

/// Style for camera switching button.
public struct FlipCameraButtonStyle: Equatable {
    /// Button background color.
    public var backgroundColor: ColorType
    /// Button image color.
    public var imageColor: ColorType
    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - backgroundColor: Button background color.
    ///   - imageColor: Button image color.
    ///   - accessibility: Accessibility related properties.
    public init(
        backgroundColor: ColorType,
        imageColor: ColorType,
        accessibility: Accessibility
    ) {
        self.backgroundColor = backgroundColor
        self.imageColor = imageColor
        self.accessibility = accessibility
    }

    mutating func apply(_ config: RemoteConfiguration.BarButtonStyle?) {
        config?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = .fill(color: $0) }

        config?.imageColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { imageColor = .fill(color: $0) }
    }
}

extension FlipCameraButtonStyle {
    static let nop = Self(
        backgroundColor: .fill(color: .clear),
        imageColor: .fill(color: .clear),
        accessibility: .nop
    )
}
