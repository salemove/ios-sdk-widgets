import Foundation
import UIKit

public extension Theme.SurveyStyle {
    struct InputQuestion {
        /// Title style.
        public var title: Theme.Text

        /// OptionButton style.
        public var option: OptionButton

        /// Text style.
        public var text: Theme.Text

        /// Placeholder style.
        public var placeholder: Theme.Text

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
                    textStyle: .headline,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                option: .init(
                    normalText: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText,
                        textStyle: .body,
                        accessibility: .init(isFontScalingEnabled: true)
                    ),
                    normalLayer: .init(
                        background: .fill(color: color.baseLight),
                        borderColor: color.baseNormal.withAlphaComponent(0.3).cgColor,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    selectedText: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText,
                        textStyle: .body,
                        accessibility: .init(isFontScalingEnabled: true)
                    ),
                    selectedLayer: .init(
                        background: .fill(color: color.baseLight),
                        borderColor: UIColor.gray.cgColor,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    highlightedText: .init(
                        color: color.systemNegative.hex,
                        font: font.bodyText,
                        textStyle: .body,
                        accessibility: .init(isFontScalingEnabled: true)
                    ),
                    highlightedLayer: .init(
                        background: .fill(color: color.baseLight),
                        borderColor: color.systemNegative.cgColor,
                        borderWidth: 1,
                        cornerRadius: 4
                    ),
                    font: font.caption,
                    textStyle: .caption1,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                text: .init(
                    color: color.baseDark.hex,
                    font: font.subtitle,
                    textStyle: .footnote,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                placeholder: .init(
                    color: color.baseNormal.hex,
                    font: font.bodyText,
                    textStyle: .footnote,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                error: .default(color: color, font: font),
                accessibility: .init(isFontScalingEnabled: true)
            )
        }

        /// Apply input question from remote configuration
        mutating func apply(
            configuration: RemoteConfiguration.SurveyInputQuestion?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            title.apply(
                configuration: configuration?.title,
                assetsBuilder: assetsBuilder
            )
            text.apply(
                configuration: configuration?.inputField?.normalText,
                assetsBuilder: assetsBuilder
            )
            placeholder.apply(
                configuration: configuration?.inputField?.placeholder,
                assetsBuilder: assetsBuilder
            )
            option.apply(
                configuration: configuration?.inputField,
                assetsBuilder: assetsBuilder
            )
            error.apply(
                configuration: configuration?.inputField?.error,
                assetsBuilder: assetsBuilder
            )
        }
    }
}
