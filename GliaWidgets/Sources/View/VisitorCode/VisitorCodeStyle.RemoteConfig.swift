import UIKit

extension VisitorCodeStyle {
    mutating func apply(
        configuration: RemoteConfiguration.VisitorCode?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyTitleConfiguration(
            configuration?.title,
            assetsBuilder: assetBuilder
        )
        actionButton.apply(
            configuration: configuration?.actionButton,
            assetsBuilder: assetBuilder
        )
        numberSlot.apply(
            text: configuration?.numberSlotText,
            background: configuration?.numberSlotBackground,
            assetsBuilder: assetBuilder
        )

        configuration?.loadingProgressColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { loadingProgressColor = $0 }

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

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

        configuration?.closeButtonColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { closeButtonColor = .fill(color: $0) }
    }

    mutating func applyTitleConfiguration(
        _ configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: titleTextStyle
        ).unwrap { titleFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }
    }
}
