import UIKit

extension SendingMessageUnavailableBannerViewStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SecureConversations?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.unavailableStatusBackground?.color.unwrap {
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
        configuration?.unavailableStatusText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        configuration?.unavailableStatusText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { iconColor = $0 }

        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.unavailableStatusText?.font),
            textStyle: textStyle
        )
        .unwrap { font = $0 }
    }
}
