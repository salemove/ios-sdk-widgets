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
        /// Accessibility related properties.
        public var accessibility: Accessibility
        /// Initializes `OptionButton` style instance.
        public init(
            normalText: Theme.Text,
            normalLayer: Theme.Layer,
            selectedText: Theme.Text,
            selectedLayer: Theme.Layer,
            highlightedText: Theme.Text,
            highlightedLayer: Theme.Layer,
            font: UIFont,
            accessibility: Accessibility = .init(isFontScalingEnabled: true)
        ) {
            self.normalText = normalText
            self.normalLayer = normalLayer
            self.selectedText = selectedText
            self.selectedLayer = selectedLayer
            self.highlightedText = highlightedText
            self.highlightedLayer = highlightedLayer
            self.font = font
            self.accessibility = accessibility
        }

        /// Apply option button from remote configuration
        mutating func applyOptionButtonConfiguration(_ optionButton: RemoteConfiguration.OptionButton?) {
            applyFontConfiguration(optionButton?.font)
            normalText.applyTextConfiguration(optionButton?.normalText)
            normalLayer.applyLayerConfiguration(optionButton?.normalLayer)
            selectedText.applyTextConfiguration(optionButton?.selectedText)
            selectedLayer.applyLayerConfiguration(optionButton?.selectedLayer)
            highlightedText.applyTextConfiguration(optionButton?.highlightedText)
            highlightedLayer.applyLayerConfiguration(optionButton?.highlightedLayer)
        }

        /// Apply option button title font from remote configuration
        private mutating func applyFontConfiguration(_ font: RemoteConfiguration.Font?) {
            UIFont.convertToFont(font: font).map {
                self.font = $0
            }
        }
    }
}
