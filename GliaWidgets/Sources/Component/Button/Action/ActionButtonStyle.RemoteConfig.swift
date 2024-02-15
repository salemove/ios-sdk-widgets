import UIKit

extension ActionButtonStyle {
    /// Applies remote configuration to `Button`.
    mutating func apply(
        configuration: RemoteConfiguration.Button?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { titleFont = $0 }

        configuration?.text?.alignment.unwrap { _ in
            // The logic for duration alignment has not been implemented
        }

        configuration?.text?.background.unwrap { _ in
            // The logic for duration background has not been implemented
        }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }

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

        configuration?.background?.cornerRadius
            .unwrap { cornerRaidus = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.shadow?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { shadowColor = $0 }

        configuration?.shadow?.offset.unwrap {
            shadowOffset = .init(width: $0, height: $0)
        }

        configuration?.shadow?.opacity.unwrap {
            shadowOpacity = Float($0)
        }
    }
}
