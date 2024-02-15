import UIKit

extension BadgeStyle {
    /// Apply badge remote configuration
    mutating func apply(
        configuration: RemoteConfiguration.Badge?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.fontColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { fontColor = $0 }

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

        configuration?.background?.border.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { borderColor = .fill(color: $0) }
            case .gradient:
                break
            }
        }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }
    }
}
