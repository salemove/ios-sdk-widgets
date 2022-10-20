import UIKit

/// Style of the operator view inside the connect view.
public struct ConnectOperatorStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    /// Color of the animated concentric circles extending from the operator's image.
    public var animationColor: UIColor

	/// Accessibility related properties.
    public var accessibility: Accessibility

    /// Style of the visitor on hold overlay view.
    public var onHoldOverlay: OnHoldOverlayStyle

    ///
    /// - Parameters:
    ///   - operatorImage: Style of the operator's image.
    ///   - animationColor: Color of the animated concentric circles extending from the operator's image.
    ///   - onHoldOverlay: Style of the visitor on hold overlay view.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        operatorImage: UserImageStyle,
        animationColor: UIColor,
        onHoldOverlay: OnHoldOverlayStyle = .engagement,
        accessibility: Accessibility = .unsupported
    ) {
        self.operatorImage = operatorImage
        self.animationColor = animationColor
        self.onHoldOverlay = onHoldOverlay
        self.accessibility = accessibility
    }

    mutating func apply(configuration: RemoteConfiguration.Operator?) {
        configuration?.image?.imageBackgroundColor.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { operatorImage.imageBackgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                operatorImage.imageBackgroundColor = .gradient(colors: colors)
            }
        }

        configuration?.image?.placeholderBackgroundColor.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { operatorImage.placeholderBackgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                operatorImage.placeholderBackgroundColor = .gradient(colors: colors)
            }
        }

        configuration?.image?.placeholderColor?.value
            .map { UIColor(hex: $0) }
            .first
            .map { operatorImage.placeholderColor = $0 }

        configuration?.animationColor?.value
            .map { UIColor(hex: $0) }
            .first
            .map { animationColor = $0 }

        configuration?.overlayColor.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { onHoldOverlay.imageColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                onHoldOverlay.imageColor = .gradient(colors: colors)
            }
        }
    }
}
