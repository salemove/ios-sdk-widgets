import UIKit

extension Theme.SurveyStyle.OptionButton {
    /// Applies the option button from remote configuration.
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

    /// Applies the option button's title's font from the remote configuration.
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
