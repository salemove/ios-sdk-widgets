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
                    textStyle: .subheadline
                ),
                tintColor: color.primary.hex,
                option: .init(
                    title: .init(
                        color: color.baseDark.hex,
                        font: font.bodyText,
                        textStyle: .body
                    ),
                    accessibility: .init(isFontScalingEnabled: true)),
                error: .default(color: color, font: font),
                accessibility: .init(isFontScalingEnabled: true)
            )
        }

        /// Apply single question from remote configuration
        mutating func apply(configuration: RemoteConfiguration.SurveySingleQuestion?) {
            option.title.apply(configuration: configuration?.option)
            title.apply(configuration: configuration?.title)
            applyTintColorConfiguration(configuration?.tintColor)
        }

        /// Apply tint color from remote configuration
        private mutating func applyTintColorConfiguration(_ tintColor: RemoteConfiguration.Color?) {
            switch tintColor?.type {
            case .fill:
                tintColor?.value.first.map { self.tintColor = $0 }
            case .gradient, .none:
                // The logic for gradient has not been implemented
                break
            }
        }
    }
}
