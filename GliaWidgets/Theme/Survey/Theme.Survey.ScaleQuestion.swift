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
                        borderColor: color.baseNormal.cgColor,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    selectedText: .init(
                        color: color.baseLight.hex,
                        font: font.bodyText
                    ),
                    selectedLayer: .init(
                        background: .fill(color: color.primary),
                        borderColor: UIColor.clear.cgColor,
                        borderWidth: 0,
                        cornerRadius: 4
                    ),
                    highlightedText: .init(
                        color: color.systemNegative.hex,
                        font: font.bodyText
                    ),
                    highlightedLayer: .init(
                        borderColor: color.systemNegative.cgColor,
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
        mutating func apply(configuration: RemoteConfiguration.SurveyScaleQuestion?) {
            title.apply(configuration: configuration?.title)
            option.apply(configuration: configuration?.optionButton)
        }
    }
}
