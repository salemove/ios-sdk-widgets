import Foundation
import UIKit

public extension Theme.SurveyStyle {
    struct SingleQuestion {
        /// Title style.
        public var title: Theme.Text
        /// Tint color.
        public var tintColor: String
        /// Option style.
        public var option: Checkbox
        /// Validation error style
        public var error: ValidationError
        /// Accessibility related properties.
        public var accessibility: Accessibility

        static func `default`(
            color: ThemeColor,
            font: ThemeFont
        ) -> Self {
            .init(
                title: .init(
                    color: color.baseDark.hex,
                    font: font.mediumSubtitle1
                ),
                tintColor: color.primary.hex,
                option: .init(
                    title: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText
                    ),
                    accessibility: .init(isFontScalingEnabled: true)),
                error: .default(color: color, font: font),
                accessibility: .init(isFontScalingEnabled: true)
            )
        }

        /// Apply single question from remote configuration
        public mutating func applyQuestionConfiguration(_ question: RemoteConfiguration.SurveySingleQuestion?) {
            option.title.applyTextConfiguration(question?.option)
            title.applyTextConfiguration(question?.title)
            applyTintColorConfiguration(question?.tintColor)
        }

        /// Apply tint color from remote configuration
        private mutating func applyTintColorConfiguration(_ tintColor: RemoteConfiguration.Color?) {
            tintColor?.type.map { tintColorType in
                switch tintColorType {
                case .fill:
                    tintColor?.value.map { colors in
                        self.tintColor = colors[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented

                    break
                }
            }
        }
    }
}
