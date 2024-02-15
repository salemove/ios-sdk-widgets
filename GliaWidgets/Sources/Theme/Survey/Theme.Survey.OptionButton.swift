import UIKit

extension Theme.SurveyStyle {
    /// Survey option button style.
    public struct OptionButton {
        /// Title text for normal state.
        public var normalText: Theme.Text

        /// Option layer for normal state.
        public var normalLayer: Theme.Layer

        /// Title text style when option is selected.
        public var selectedText: Theme.Text

        /// Layer style when option is selected.
        public var selectedLayer: Theme.Layer

        /// Title text style when option is highlighted.
        public var highlightedText: Theme.Text

        /// Layer style when option is highlighted.
        public var highlightedLayer: Theme.Layer

        /// Title font.
        public var font: UIFont

        /// Text style ot the title.
        public var textStyle: UIFont.TextStyle

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - normalText: Title text for normal state.
        ///   - normalLayer: Option layer for normal state.
        ///   - selectedText: Title text style when option is selected.
        ///   - selectedLayer: Layer style when option is selected.
        ///   - highlightedText: Title text style when option is highlighted.
        ///   - highlightedLayer: Layer style when option is highlighted.
        ///   - font: Title font.
        ///   - textStyle: Text style ot the title.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            normalText: Theme.Text,
            normalLayer: Theme.Layer,
            selectedText: Theme.Text,
            selectedLayer: Theme.Layer,
            highlightedText: Theme.Text,
            highlightedLayer: Theme.Layer,
            font: UIFont,
            textStyle: UIFont.TextStyle = .body,
            accessibility: Accessibility = .init(isFontScalingEnabled: true)
        ) {
            self.normalText = normalText
            self.normalLayer = normalLayer
            self.selectedText = selectedText
            self.selectedLayer = selectedLayer
            self.highlightedText = highlightedText
            self.highlightedLayer = highlightedLayer
            self.font = font
            self.textStyle = textStyle
            self.accessibility = accessibility
        }
    }
}
