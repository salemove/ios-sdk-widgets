import UIKit

extension NumberSlotStyle {
    mutating func apply(
        text: RemoteConfiguration.Text?,
        background: RemoteConfiguration.Layer?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(text?.font),
            textStyle: numberStyle
        ).unwrap { numberFont = $0 }

        text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { numberColor = $0 }

        background?.color.unwrap {
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

        background?.cornerRadius.unwrap { cornerRadius = $0 }
        background?.borderWidth.unwrap { borderWidth = $0 }
        background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }
    }
}
