import UIKit

extension AttachmentSourceItemStyle {
    func apply(
        configuration: RemoteConfiguration.AttachmentSource?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.tintColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { iconColor = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: titleTextStyle
        ).unwrap { titleFont = $0 }
    }
}
