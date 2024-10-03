import UIKit

extension EntryWidgetStyle {
    mutating func apply(
        configuration: RemoteConfiguration.EntryWidget?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyBackground(configuration: configuration?.background)
        applyDivider(configuration: configuration?.mediaTypeItems?.dividerColor)
        applyErrorTitle(
            configuration: configuration?.errorTitle,
            assetsBuilder: assetsBuilder
        )
        applyErrorMessage(
            configuration: configuration?.errorMessage,
            assetsBuilder: assetsBuilder
        )
        errorButton.apply(
            configuration: configuration?.errorButton,
            assetsBuilder: assetsBuilder
        )
        mediaTypeItem.apply(
            configuration: configuration?.mediaTypeItems?.mediaTypeItem,
            assetsBuilder: assetsBuilder
        )
    }
}

private extension EntryWidgetStyle {
    mutating func applyBackground(configuration: RemoteConfiguration.Layer?) {
        configuration?.color.unwrap {
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
        configuration?.cornerRadius.unwrap {
            cornerRadius = $0
        }
    }

    mutating func applyErrorMessage(
        configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration.unwrap {
            UIFont.convertToFont(
                uiFont: assetsBuilder.fontBuilder($0.font),
                textStyle: errorMessageStyle
            ).unwrap { errorMessageFont = $0 }

            $0.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { errorMessageColor = $0 }
        }
    }

    mutating func applyErrorTitle(
        configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration.unwrap {
            UIFont.convertToFont(
                uiFont: assetsBuilder.fontBuilder($0.font),
                textStyle: errorTitleStyle
            ).unwrap { errorTitleFont = $0 }

            $0.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { errorTitleColor = $0 }
        }
    }

    mutating func applyDivider(configuration: RemoteConfiguration.Color?) {
        configuration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { dividerColor = $0 }
    }
}
