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
        /// Initializes `OptionButton` style instance.
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

        /// Apply option button from remote configuration
        mutating func apply(
            configuration: RemoteConfiguration.OptionButton?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            applyFontConfiguration(
                configuration?.font,
                assetsBuilder: assetsBuilder
            )
            normalText.apply(
                configuration: configuration?.normalText,
                assetsBuilder: assetsBuilder
            )
            normalLayer.apply(configuration: configuration?.normalLayer)
            selectedText.apply(
                configuration: configuration?.selectedText,
                assetsBuilder: assetsBuilder
            )
            selectedLayer.apply(configuration: configuration?.selectedLayer)
            highlightedText.apply(
                configuration: configuration?.highlightedText,
                assetsBuilder: assetsBuilder
            )
            highlightedLayer.apply(configuration: configuration?.highlightedLayer)
        }

        /// Apply option button title font from remote configuration
        private mutating func applyFontConfiguration(
            _ font: RemoteConfiguration.Font?,
            assetsBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetsBuilder.fontBuilder(font),
                textStyle: textStyle
            ).unwrap { self.font = $0 }
        }
    }
}
