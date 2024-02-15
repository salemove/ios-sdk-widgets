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
        systemMessageStyle.apply(
            configuration: configuration?.systemMessage,
            assetsBuilder: assetsBuilder
        )
        gliaVirtualAssistant.apply(
            configuration: configuration?.gva,
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
