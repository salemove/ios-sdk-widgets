import Foundation
import UIKit

public extension Theme.SurveyStyle {
    struct InputQuestion {
        /// Title style.
        public var title: Theme.Text
        /// OptionButton style.
        public var option: OptionButton
        /// Background style.
        public var background: Theme.Layer
        /// Text style.
        public var text: Theme.Text
        /// Validation error style.
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
                    font: font.mediumSubtitle1,
                    textStyle: .subheadline
                ),
                option: .init(
                    normalText: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText,
                        textStyle: .body
                    ),
                    normalLayer: .init(
                        borderColor: color.baseNormal.cgColor,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    selectedText: .init(
                        color: color.baseLight.hex,
                        font: font.bodyText,
                        textStyle: .body
                    ),
                    selectedLayer: .init(
                        background: .fill(color: color.primary),
                        borderColor: UIColor.gray.cgColor,
                        borderWidth: 0,
                        cornerRadius: 4
                    ),
                    highlightedText: .init(
                        color: color.systemNegative.hex,
                        font: font.bodyText,
                        textStyle: .body
                    ),
                    highlightedLayer: .init(
                        borderColor: color.systemNegative.cgColor,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    font: font.caption,
                    textStyle: .caption1,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                background: Theme.Layer(
                    background: .fill(color: color.background),
                    borderColor: color.baseNormal.cgColor,
                    borderWidth: 1,
                    cornerRadius: 5
                ),
                text: .init(
                    color: color.baseDark.hex,
                    font: font.subtitle,
                    textStyle: .footnote
                ),
                error: .default(color: color, font: font),
                accessibility: .init(isFontScalingEnabled: true)
            )
        }

        /// Apply input question from remote configuration
        mutating func apply(configuration: RemoteConfiguration.SurveyInputQuestion?) {
            title.apply(configuration: configuration?.title)
            text.apply(configuration: configuration?.text)
            background.apply(configuration: configuration?.background)
            option.apply(configuration: configuration?.option)
        }
    }
}
