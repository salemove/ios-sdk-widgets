import UIKit

extension SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Text?,
        layerConfiguration: RemoteConfiguration.Layer?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.font),
            textStyle: textFontStyle
        ).unwrap { textFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        layerConfiguration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        layerConfiguration?.borderWidth.unwrap { borderWidth = $0 }
        layerConfiguration?.cornerRadius.unwrap { cornerRadius = $0 }
        layerConfiguration?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }
    }
}
