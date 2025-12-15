import UIKit

extension MediaQualityIndicatorStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: .body
        ).unwrap { font = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { foreground = $0 }

        configuration?.background.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { background = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                background = .gradient(colors: colors)
            }
        }

        configuration?.alignment.unwrap {
            alignment = $0.asNsTextAlignment
        }
    }
}
