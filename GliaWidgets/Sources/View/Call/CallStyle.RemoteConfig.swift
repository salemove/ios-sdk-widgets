import UIKit

extension CallStyle {
    /// Applies call configuration from remote configuration
    func apply(
        configuration: RemoteConfiguration.Call?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        buttonBar.applyBarConfiguration(
            configuration?.buttonBar,
            assetsBuilder: assetsBuilder
        )

        applyBackgroundConfiguration(configuration?.background)
        applyOperatorConfiguration(
            configuration?.callOperator,
            assetsBuilder: assetsBuilder
        )
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        applyDurationConfiguration(
            configuration?.duration,
            assetsBuilder: assetsBuilder
        )
        applyTopTextConfiguration(
            configuration?.topText,
            assetsBuilder: assetsBuilder
        )
        applyBottomTextConfiguration(
            configuration?.bottomText,
            assetsBuilder: assetsBuilder
        )

        connect.apply(
            configuration: configuration?.connect,
            assetsBuilder: assetsBuilder
        )

        flipCameraButtonStyle.apply(configuration?.visitorVideo?.flipCameraButton)
    }

    /// Applies `bottomText` from remote configuration.
    private func applyBottomTextConfiguration(
        _ bottomText: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        bottomText?.alignment.unwrap { _ in
            // The logic for bottomText alignment has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(bottomText?.font),
            textStyle: bottomTextStyle
        ).unwrap { bottomTextFont = $0 }

        bottomText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { bottomTextColor = $0 }
    }

    /// Applies `topText` from remote configuration.
    private func applyTopTextConfiguration(
        _ topText: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        topText?.alignment.unwrap { _ in
            // The logic for topText alignment has not been implemented
        }

        topText?.background.unwrap { _ in
            // The logic for topText background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(topText?.font),
            textStyle: topTextStyle
        ).unwrap { topTextFont = $0 }

        topText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { topTextColor = $0 }
    }

    /// Applies duration from remote configuration.
    private func applyDurationConfiguration(
        _ duration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        duration?.alignment.unwrap { _ in
            // The logic for duration alignment has not been implemented
        }

        duration?.background.unwrap { _ in
            // The logic for duration background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(duration?.font),
            textStyle: durationTextStyle
        ).unwrap { durationFont = $0 }

        duration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { durationColor = $0 }
    }

    /// Applies operator from remote configuration.
    private func applyOperatorConfiguration(
        _ callOperator: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        callOperator?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { self.operatorNameColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(callOperator?.font),
            textStyle: operatorNameTextStyle
        ).unwrap { operatorNameFont = $0 }
    }

    /// Applies background from remote configuration.
    private func applyBackgroundConfiguration(_ background: RemoteConfiguration.Layer?) {
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
    }
}
