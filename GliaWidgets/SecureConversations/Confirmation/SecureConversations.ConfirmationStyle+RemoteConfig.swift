import UIKit

extension SecureConversations.ConfirmationStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SecureConversationsConfirmationScreen?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        configuration?.iconColor?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap { confirmationImageTint = $0 }

        configuration?.title?.foreground?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap {
                titleStyle.color = $0
            }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.title?.font),
            textStyle: .title3
        ).unwrap { titleStyle.font = $0 }

        configuration?.subtitle?.foreground?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap {
                subtitleStyle.color = $0
            }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.subtitle?.font),
            textStyle: .body
        ).unwrap { subtitleStyle.font = $0 }

        configuration?.checkMessagesButton?.text?.foreground?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap {
                checkMessagesButtonStyle.textColor = $0
            }

        configuration?.checkMessagesButton?.background?.color?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap {
                checkMessagesButtonStyle.backgroundColor = $0
            }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.checkMessagesButton?.text?.font),
            textStyle: .title3
        ).unwrap { checkMessagesButtonStyle.font = $0 }

        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }
    }
}
