import UIKit

extension ChatMessageEntryStateStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Input?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { messageColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: messageTextStyle
        ).unwrap { messageFont = $0 }

        configuration?.placeholder?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { placeholderColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.placeholder?.font),
            textStyle: placeholderTextStyle
        ).unwrap { placeholderFont = $0 }

        configuration?.separator?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { separatorColor = $0 }
        // TODO: Add Unified customization (MOB-3762)
        configuration?.mediaButton?.tintColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { mediaButton.enabled.color = $0 }
        // TODO: Add Unified customization (MOB-3762)
        configuration?.sendButton?.tintColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { sendButton.enabled.color = $0 }

        uploadList.apply(
            configuration: configuration?.fileUploadBar,
            assetsBuilder: assetsBuilder
        )
    }
}
