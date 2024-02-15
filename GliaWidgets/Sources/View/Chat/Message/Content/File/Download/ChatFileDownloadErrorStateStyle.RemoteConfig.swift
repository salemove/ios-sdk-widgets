import UIKit

extension ChatFileDownloadErrorStateStyle {
    func apply(
        configuration: RemoteConfiguration.FileErrorState?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.info?.font),
            textStyle: infoTextStyle
        ).unwrap { infoFont = $0 }

        configuration?.info?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { infoColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.separator?.font),
            textStyle: separatorTextStyle
        ).unwrap { separatorFont = $0 }

        configuration?.separator?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { separatorTextColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.retry?.font),
            textStyle: retryTextStyle
        ).unwrap { retryFont = $0 }

        configuration?.retry?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { retryTextColor = $0 }
    }
}
