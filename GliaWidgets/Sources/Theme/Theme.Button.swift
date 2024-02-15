import Foundation
import UIKit

extension Theme {
    /// Button style.
    public struct Button: Equatable {
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

        /// - Parameters:
        ///   - background: Background hex color.
        ///   - title: Title style.
        ///   - cornerRadius: Button corner radius.
        ///   - borderWidth: Button border width.
        ///   - borderColor: Button border hex color.
        ///   - shadow: Button shadow.
        ///   - accessibility: Accessibility related properties.
        ///
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
                font: actionButtonStyle.titleFont,
                textStyle: actionButtonStyle.textStyle,
                accessibility: .init(isFontScalingEnabled: accessibility.isFontScalingEnabled)
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
    }
}
