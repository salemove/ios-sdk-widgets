import UIKit

extension SecureMessagingTopBannerViewStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SecureConversations?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.topBannerBackground?.color.unwrap {
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

        configuration?.topBannerDividerColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { dividerColor = $0 }

        configuration?.topBannerText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        configuration?.topBannerDropDownIconColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { buttonImageColor = $0 }

        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.topBannerText?.font),
            textStyle: textStyle
        )
        .unwrap { font = $0 }
    }
}
