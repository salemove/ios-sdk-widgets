import UIKit

public extension Theme.SurveyStyle {
    /// ValidationErrorView style.
    struct ValidationError {
        /// Validation message
        public var message: String
        /// Foreground hex color.
        public var color: String
        /// Message font.
        public var font: UIFont
        /// Accessibility related properties.
        public var accessibility: Accessibility

        static func `default`(
            color: ThemeColor,
            font: ThemeFont
        ) -> Self {
            .init(
                message: Localization.Survey.Action.validationError,
                color: color.systemNegative.hex,
                font: font.caption,
                accessibility: .init(
                    label: Localization.Survey.Validation.Title.Accessibility.label,
                    isFontScalingEnabled: true
                )
            )
        }
    }
}
