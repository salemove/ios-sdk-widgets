import UIKit

extension SecureConversations.WelcomeStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SecureConversationsWelcomeScreen?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetBuilder
        )
        welcomeTitleStyle.apply(
            configuration: configuration?.welcomeTitle,
            assetBuilder: assetBuilder
        )
        titleImageStyle.apply(
            configuration: configuration?.titleImage,
            assetBuilder: assetBuilder
        )
        welcomeSubtitleStyle.apply(
            configuration: configuration?.welcomeSubtitle,
            assetBuilder: assetBuilder
        )
        checkMessagesButtonStyle.apply(
            configuration: configuration?.checkMessagesButton,
            assetBuilder: assetBuilder
        )
        messageTitleStyle?.apply(
            configuration: configuration?.messageTitle,
            assetBuilder: assetBuilder
        )
        messageTextViewStyle.apply(
            normal: configuration?.messageTextViewNormal,
            disabled: configuration?.messageTextViewDisabled,
            active: configuration?.messageTextViewActive,
            layer: configuration?.messageTextViewLayer,
            assetBuilder: assetBuilder
        )
        sendButtonStyle.apply(
            enabled: configuration?.enabledSendButton,
            disabled: configuration?.disabledSendButton,
            loading: configuration?.loadingSendButton,
            activityIndicatorColor: configuration?.activityIndicatorColor,
            assetBuilder: assetBuilder
        )
        messageWarningStyle.apply(
            textConfiguration: configuration?.messageWarning,
            iconConfiguration: configuration?.messageWarningIconColor,
            assetBuilder: assetBuilder
        )
        filePickerButtonStyle.apply(
            configuration: configuration?.filePickerButton,
            disabledConfiguration: configuration?.filePickerButtonDisabled
        )
        attachmentListStyle.apply(
            configuration: configuration?.attachmentList,
            assetsBuilder: assetBuilder
        )
        pickMediaStyle.apply(
            configuration: configuration?.pickMedia,
            assetsBuilder: assetBuilder
        )
        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }
    }
}
