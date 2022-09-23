import Foundation
import UIKit

public extension Theme.SurveyStyle {
    struct ScaleQuestion {
        /// Title style.
        public var title: Theme.Text
        /// OptionButton style.
        public var option: OptionButton
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
                option: .init(
                    normalText: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText
                    ),
                    normalLayer: .init(
                        borderColor: color.baseNormal.hex,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    selectedText: .init(
                        color: color.baseLight.hex,
                        font: font.bodyText
                    ),
                    selectedLayer: .init(
                        background: color.primary.hex,
                        borderColor: "",
                        borderWidth: 0,
                        cornerRadius: 4
                    ),
                    highlightedText: .init(
                        color: color.systemNegative.hex,
                        font: font.bodyText
                    ),
                    highlightedLayer: .init(
                        borderColor: color.systemNegative.hex,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    font: font.buttonLabel,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                error: .default(color: color, font: font),
                accessibility: .init(isFontScalingEnabled: true)
            )
        }

        /// Apply scale question from remote configuration
        mutating func applyQuestionConfiguration(_ question: RemoteConfiguration.SurveyScaleQuestion?) {
            title.applyTextConfiguration(question?.title)
            option.applyOptionButtonConfiguration(question?.optionButton)
        }
    }
}
