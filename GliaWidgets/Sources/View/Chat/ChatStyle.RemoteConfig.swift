import UIKit

extension ChatStyle {
    func apply(
        configuration: RemoteConfiguration.Chat?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        connect.apply(
            configuration: configuration?.connect,
            assetsBuilder: assetsBuilder
        )
        visitorMessageStyle.apply(
            configuration: configuration?.visitorMessage,
            assetsBuilder: assetsBuilder
        )
        operatorMessageStyle.apply(
            configuration: configuration?.operatorMessage,
            assetsBuilder: assetsBuilder
        )
        messageEntry.apply(
            configuration: configuration?.input,
            disabledConfiguration: configuration?.inputDisabled,
            assetsBuilder: assetsBuilder
        )
        choiceCardStyle.apply(
            configuration: configuration?.responseCard,
            assetsBuilder: assetsBuilder
        )
        audioUpgrade.apply(
            configuration: configuration?.audioUpgrade,
            assetsBuilder: assetsBuilder
        )
        videoUpgrade.apply(
            configuration: configuration?.videoUpgrade,
            assetsBuilder: assetsBuilder
        )
        callBubble.apply(
            configuration: configuration?.bubble,
            assetsBuilder: assetsBuilder
        )
        pickMedia.apply(
            configuration: configuration?.attachmentSourceList,
            assetsBuilder: assetsBuilder
        )
        unreadMessageIndicator.apply(
            configuration: configuration?.unreadIndicator,
            assetsBuilder: assetsBuilder
        )
        operatorTypingIndicator.apply(configuration: configuration?.typingIndicator)
        unreadMessageDivider.apply(
            lineColor: configuration?.newMessagesDividerColor,
            text: configuration?.newMessagesDividerText,
            assetBuilder: assetsBuilder
        )
        applyAdditionalStyles(
            configuration: configuration,
            assetsBuilder: assetsBuilder
        )
    }

    private func applyAdditionalStyles(
        configuration: RemoteConfiguration.Chat?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        secureTranscriptHeader.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        systemMessageStyle.apply(
            configuration: configuration?.systemMessage,
            assetsBuilder: assetsBuilder
        )
        gliaVirtualAssistant.apply(
            configuration: configuration?.gva,
            assetBuilder: assetsBuilder
        )
        secureMessagingTopBannerStyle.apply(
            configuration: configuration?.secureMessaging,
            assetBuilder: assetsBuilder
        )
        secureMessagingExpandedTopBannerItemsStyle.apply(
            configuration: configuration?.secureMessaging?.mediaTypeItems,
            assetBuilder: assetsBuilder
        )
        secureMessagingBottomBannerStyle.apply(
            configuration: configuration?.secureMessaging,
            assetBuilder: assetsBuilder
        )
        sendingMessageUnavailableBannerViewStyle.apply(
            configuration: configuration?.secureMessaging,
            assetBuilder: assetsBuilder
        )
        applyBackground(color: configuration?.background?.color)
    }

    private func applyBackground(color: RemoteConfiguration.Color?) {
        color.unwrap {
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
