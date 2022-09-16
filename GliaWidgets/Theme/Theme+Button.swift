import Foundation
import UIKit

extension Theme {

    /// Button style.
    public struct Button {
        /// Background hex color.
        public var background: String?
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
            background: String?,
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
            acitonButtonStyle: ActionButtonStyle,
            accessibility: Accessibility
        ) {
            self.background = acitonButtonStyle.backgroundColor == .clear ? nil : acitonButtonStyle.backgroundColor.hex
            self.title = .init(
                color: acitonButtonStyle.titleColor.hex,
                font: acitonButtonStyle.titleFont
            )
            self.cornerRadius = acitonButtonStyle.cornerRaidus ?? 0
            self.borderWidth = acitonButtonStyle.borderWidth ?? 0
            self.borderColor = acitonButtonStyle.borderColor?.hex

            self.shadow = .init(
                color: acitonButtonStyle.shadowColor?.hex ?? Shadow.standard.color,
                offset: acitonButtonStyle.shadowOffset ?? Shadow.standard.offset,
                opacity: acitonButtonStyle.shadowOpacity ?? Shadow.standard.opacity,
                radius: acitonButtonStyle.shadowRadius ?? Shadow.standard.radius
            )
            self.accessibility = accessibility
        }

        /// Apply default question button from remote configuration
        public mutating func applyQuestionConfiguration(_ question: RemoteConfiguration.SurveyButton?) {
            applyBackgroundConfiguration(question?.background)
            title.applyTextConfiguration(question?.title)
            shadow.applyShadowConfiguration(question?.shadow)
        }

        /// Apply button background from remote configuration
        private mutating func applyBackgroundConfiguration(_ background: RemoteConfiguration.Layer?) {
            background?.color?.type.map { backgroundType in
                switch backgroundType {
                case .fill:
                    background?.color?.value.map { colors in
                        self.background = colors[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented

                    break
                }
            }

            background?.cornerRadius.map { cornerRadius in
                self.cornerRadius = cornerRadius
            }

            background?.borderWidth.map { borderWidth in
                self.borderWidth = borderWidth
            }

            background?.color?.type.map { borderColorType in
                switch borderColorType {
                case .fill:
                    background?.color?.value.map { borderColors in
                        self.borderColor = borderColors[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented

                    break
                }
            }
        }
    }
}
