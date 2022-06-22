import Foundation

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
    }
}
