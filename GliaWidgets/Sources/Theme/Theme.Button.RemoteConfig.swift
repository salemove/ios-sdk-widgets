import UIKit

extension Theme.Button {
    /// Applies remote configuration to the default question button.
    mutating func apply(
        configuration: RemoteConfiguration.Button?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyBackground(configuration?.background)
        title.apply(
            configuration: configuration?.text,
            assetsBuilder: assetsBuilder
        )
        shadow.apply(configuration: configuration?.shadow)
    }
}

private extension Theme.Button {
    /// Applies remote configuration to the button background.
    mutating func applyBackground(_ background: RemoteConfiguration.Layer?) {
        background?.color.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { self.background = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                self.background = .gradient(colors: colors)
            }
        }

        background?.cornerRadius.unwrap {
            cornerRadius = $0
        }

        background?.borderWidth.unwrap {
            borderWidth = $0
        }

        background?.border?.value
            .first
            .unwrap { borderColor = $0 }
    }
}
