import UIKit

// MARK: - Internal
extension AlertStyle {
    /// Apply alert customization from remote configuration
    mutating func apply(
        configuration: RemoteConfiguration.Alert?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        firstLinkAction.apply(
            configuration: configuration?.linkButton,
            assetsBuilder: assetsBuilder
        )
        secondLinkAction.apply(
            configuration: configuration?.linkButton,
            assetsBuilder: assetsBuilder
        )
        positiveAction.apply(
            configuration: configuration?.positiveButton,
            assetsBuilder: assetsBuilder
        )
        negativeAction.apply(
            configuration: configuration?.negativeButton,
            assetsBuilder: assetsBuilder
        )
        applyTitleConfiguration(
            configuration?.title,
            assetsBuilder: assetsBuilder
        )
        applyTitleImageConfiguration(configuration?.titleImageColor)
        applyMessageConfiguration(
            configuration?.message,
            assetsBuilder: assetsBuilder
        )
    }
}

// MARK: - Private
private extension AlertStyle {
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

    mutating func applyTitleImageConfiguration(_ configuration: RemoteConfiguration.Color?) {
        configuration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleImageColor = $0 }
    }

    mutating func applyMessageConfiguration(
        _ configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: messageTextStyle
        ).unwrap { messageFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { messageColor = $0 }
    }

    mutating func applyBackgroundConfiguration(_ configuration: RemoteConfiguration.Color?) {
        configuration.unwrap {
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
    }

    mutating func applyButtonAxisConfiguration(_ configuration: RemoteConfiguration.Axis?) {
        configuration.unwrap { axis in
            switch axis {
            case .horizontal:
                actionAxis = .horizontal
            case .vertical:
                actionAxis = .vertical
            }
        }
    }

    mutating func applyCloseButtonConfiguration(_ configuration: RemoteConfiguration.Color?) {
        configuration.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { closeButtonColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                closeButtonColor = .gradient(colors: colors)
            }
        }
    }
}
