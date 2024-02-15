import UIKit

extension ScreenSharingViewStyle {
    mutating func apply(
        configuration: RemoteConfiguration.ScreenSharing?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetBuilder
        )

        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.message?.font),
            textStyle: messageTextStyle
        ).unwrap { messageTextFont = $0 }

        configuration?.message?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { messageTextColor = $0 }

        buttonStyle.apply(
            configuration: configuration?.endButton,
            assetsBuilder: assetBuilder
        )

        configuration?.background?.color.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }
    }
}
