import UIKit

extension EntryWidgetStyle.MediaTypeItemStyle {
    mutating func apply(
        configuration: RemoteConfiguration.MediaTypeItem?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
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

        configuration?.iconColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { iconColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                iconColor = .gradient(colors: colors)
            }
        }

        configuration?.title?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.title?.font),
            textStyle: messageTextStyle
        ).unwrap { titleFont = $0 }

        configuration?.message?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { messageColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.message?.font),
            textStyle: messageTextStyle
        ).unwrap { messageFont = $0 }

        configuration?.loadingTintColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { loading.loadingTintColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                loading.loadingTintColor = .gradient(colors: colors)
            }
        }
    }
}
