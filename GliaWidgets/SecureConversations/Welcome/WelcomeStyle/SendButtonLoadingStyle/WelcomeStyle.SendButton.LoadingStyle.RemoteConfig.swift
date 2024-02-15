import UIKit

extension SecureConversations.WelcomeStyle.SendButtonLoadingStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Button?,
        activityIndicatorColor: RemoteConfiguration.Color?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        if let borderWidth = configuration?.background?.borderWidth {
            self.borderWidth = borderWidth
        }

        activityIndicatorColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { self.activityIndicatorColor = $0 }

        if let cornerRadius = configuration?.background?.cornerRadius {
            self.cornerRadius = cornerRadius
        }
    }
}
