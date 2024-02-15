import UIKit

extension FileUploadStateStyle {
    func apply(
        configuration: RemoteConfiguration.FileState?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { infoColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.info?.font),
            textStyle: infoTextStyle
        ).unwrap { infoFont = $0 }
    }
}
