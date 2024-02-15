import UIKit

extension SecureConversations.WelcomeStyle.MessageWarningStyle {
    mutating func apply(
        textConfiguration: RemoteConfiguration.Text?,
        iconConfiguration: RemoteConfiguration.Color?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(textConfiguration?.font),
            textStyle: textStyle
        ).unwrap { textFont = $0 }

        iconConfiguration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { iconColor = $0 }

        textConfiguration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }
    }
}
