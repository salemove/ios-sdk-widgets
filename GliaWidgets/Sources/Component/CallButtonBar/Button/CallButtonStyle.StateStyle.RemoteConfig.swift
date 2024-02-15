import UIKit

extension CallButtonStyle.StateStyle {
    mutating func apply(
        configuration: RemoteConfiguration.BarButtonStyle?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background.unwrap {
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

        configuration?.imageColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { imageColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageColor = .gradient(colors: colors)
            }
        }

        configuration?.title?.alignment.unwrap { _ in
            // The logic for title alignment has not been implemented
        }

        configuration?.title?.background.unwrap { _ in
            // The logic for title background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.title?.font),
            textStyle: textStyle
        ).unwrap { titleFont = $0 }

        configuration?.title?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }
    }
}
