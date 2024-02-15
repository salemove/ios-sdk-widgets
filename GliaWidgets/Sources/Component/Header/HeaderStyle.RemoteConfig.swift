import UIKit

extension HeaderStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Header?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
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

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { titleFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }

        configuration?.background?.border.unwrap { _ in
            // The logic for header border has not been implemented
        }

        configuration?.background?.borderWidth.unwrap { _ in
            // The logic for header borderWidth has not been implemented
        }

        configuration?.background?.cornerRadius.unwrap { _ in
            // The logic for header cornerRadius has not been implemented
        }

        configuration?.text?.alignment.unwrap { _ in
            // The logic for title alignment has not been implemented
        }

        configuration?.text?.background.unwrap { _ in
            // The logic for title background has not been implemented
        }

        backButton?.apply(configuration: configuration?.backButton)
        closeButton.apply(configuration: configuration?.closeButton)
        endButton.apply(
            configuration: configuration?.endButton,
            assetsBuilder: assetsBuilder
        )
        endScreenShareButton.apply(configuration: configuration?.endScreenSharingButton)
    }
}
