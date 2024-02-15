import UIKit

extension SecureConversations.WelcomeStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SecureConversationsWelcomeScreen?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        welcomeTitleStyle.apply(
            configuration: configuration?.welcomeTitle,
            assetBuilder: assetsBuilder
        )
        titleImageStyle.apply(
            configuration: configuration?.titleImage,
            assetBuilder: assetsBuilder
        )
        welcomeSubtitleStyle.apply(
            configuration: configuration?.welcomeSubtitle,
            assetBuilder: assetsBuilder
        )
        checkMessagesButtonStyle.apply(
            configuration: configuration?.checkMessagesButton,
            assetBuilder: assetsBuilder
        )
        messageTitleStyle?.apply(
            configuration: configuration?.messageTitle,
            assetBuilder: assetsBuilder
        )
        messageTextViewStyle.apply(
            normal: configuration?.messageTextViewNormal,
            disabled: configuration?.messageTextViewDisabled,
            active: configuration?.messageTextViewActive,
            layer: configuration?.messageTextViewLayer,
            assetBuilder: assetsBuilder
        )
        sendButtonStyle.apply(
            enabled: configuration?.enabledSendButton,
            disabled: configuration?.disabledSendButton,
            loading: configuration?.loadingSendButton,
            activityIndicatorColor: configuration?.activityIndicatorColor,
            assetBuilder: assetsBuilder
        )
        messageWarningStyle.apply(
            textConfiguration: configuration?.messageWarning,
            iconConfiguration: configuration?.messageWarningIconColor,
            assetBuilder: assetsBuilder
        )
        filePickerButtonStyle.apply(
            configuration: configuration?.filePickerButton,
            disabledConfiguration: configuration?.filePickerButtonDisabled
        )
        attachmentListStyle.apply(
            configuration: configuration?.attachmentList,
            assetsBuilder: assetsBuilder
        )
        pickMediaStyle.apply(
            configuration: configuration?.pickMedia,
            assetsBuilder: assetsBuilder
        )
        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }
    }
}
