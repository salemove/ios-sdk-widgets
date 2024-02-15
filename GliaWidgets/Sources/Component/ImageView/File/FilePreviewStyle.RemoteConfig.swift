import UIKit

extension FilePreviewStyle {
    func apply(
        configuration: RemoteConfiguration.FilePreview?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.errorBackground?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { errorBackgroundColor = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { fileColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: fileTextStyle
        ).unwrap { fileFont = $0 }

        configuration?.errorIcon?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { errorIconColor = $0 }
    }
}
