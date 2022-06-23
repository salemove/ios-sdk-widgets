import UIKit

extension Theme.SurveyStyle {
    /// Survey option checkbox style.
    public struct Checkbox {
        /// Title text style.
        public var title: Theme.Text
        /// Accessibility related properties.
        public var accessibility: Accessibility
        /// Initializes `OptionButton` style instance.
        public init(
            title: Theme.Text,
            accessibility: Accessibility = .init(isFontScalingEnabled: true)
        ) {
            self.title = title
            self.accessibility = accessibility
        }
    }
}
