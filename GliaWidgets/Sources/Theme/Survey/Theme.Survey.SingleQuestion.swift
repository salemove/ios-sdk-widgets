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
                    font: font.mediumSubtitle1,
                    textStyle: .subheadline,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                tintColor: color.primary.hex,
                option: .init(
                    title: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText,
                        textStyle: .body,
                        accessibility: .init(isFontScalingEnabled: true)
                    ),
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                error: .default(color: color, font: font),
                accessibility: .init(isFontScalingEnabled: true)
            )
        }

        /// Apply single question from remote configuration
        mutating func apply(
            configuration: RemoteConfiguration.SurveySingleQuestion?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            option.title.apply(
                configuration: configuration?.option,
                assetsBuilder: assetsBuilder
            )
            title.apply(
                configuration: configuration?.title,
                assetsBuilder: assetsBuilder
            )
            applyTintColorConfiguration(configuration?.tintColor)
        }

        /// Apply tint color from remote configuration
        private mutating func applyTintColorConfiguration(_ tintColor: RemoteConfiguration.Color?) {
            tintColor?.value
                .first
                .unwrap { self.tintColor = $0 }
        }
    }
}
