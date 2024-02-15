import UIKit

extension ChatCallUpgradeStyle {
    func apply(
        configuration: RemoteConfiguration.Upgrade?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.iconColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { iconColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { textFont = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.description?.font),
            textStyle: durationTextStyle
        ).unwrap { durationFont = $0 }

        configuration?.description?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { durationColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.background?.cornerRadius
            .unwrap { cornerRadius = $0 }
    }
}
