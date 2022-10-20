import Foundation
import UIKit

extension Theme {

    /// Button style.
    public struct Button {
        /// Background hex color.
        public var background: ColorType
        /// Title style.
        public var title: Text
        /// Button corner radius.
        public var cornerRadius: CGFloat
        /// Button border width.
        public var borderWidth: CGFloat = 0
        /// Button border hex color.
        public var borderColor: String?
        /// Button shadow.
        public var shadow: Shadow
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// Initializes `Button` style instance.
        public init(
            background: ColorType,
            title: Theme.Text,
            cornerRadius: CGFloat,
            borderWidth: CGFloat = 0,
            borderColor: String? = nil,
            shadow: Shadow = .standard,
            accessibility: Accessibility = .unsupported
        ) {
            self.background = background
            self.title = title
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.shadow = shadow
            self.accessibility = accessibility
        }

        public init(
            actionButtonStyle: ActionButtonStyle,
            accessibility: Accessibility
        ) {
            self.background = actionButtonStyle.backgroundColor
            self.title = .init(
                color: actionButtonStyle.titleColor.hex,
                font: actionButtonStyle.titleFont
            )
            self.cornerRadius = actionButtonStyle.cornerRaidus ?? 0
            self.borderWidth = actionButtonStyle.borderWidth ?? 0
            self.borderColor = actionButtonStyle.borderColor?.hex

            self.shadow = .init(
                color: actionButtonStyle.shadowColor?.hex ?? Shadow.standard.color,
                offset: actionButtonStyle.shadowOffset ?? Shadow.standard.offset,
                opacity: actionButtonStyle.shadowOpacity ?? Shadow.standard.opacity,
                radius: actionButtonStyle.shadowRadius ?? Shadow.standard.radius
            )
            self.accessibility = accessibility
        }

        /// Apply default question button from remote configuration
        mutating func apply(configuration: RemoteConfiguration.Button?) {
            applyBackground(configuration?.background)
            title.apply(configuration: configuration?.text)
            shadow.apply(configuration: configuration?.shadow)
        }
    }
}

private extension Theme.Button {
    /// Apply button background from remote configuration
    mutating func applyBackground(_ background: RemoteConfiguration.Layer?) {
        background?.color.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { self.background = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                self.background = .gradient(colors: colors)
            }
        }

        background?.cornerRadius.map {
            cornerRadius = $0
        }

        background?.borderWidth.map {
            borderWidth = $0
        }

        background?.border.map {
            $0.value
                .first
                .map { borderColor = $0 }
        }
    }
}
