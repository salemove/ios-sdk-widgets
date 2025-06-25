import Foundation

extension Theme {
    func apply(
        configuration: RemoteConfiguration,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        color.apply(
            configuration: configuration.globalColors
        )

        call.apply(
            configuration: configuration.callScreen,
            assetsBuilder: assetsBuilder
        )
        survey.apply(
            configuration: configuration.surveyScreen,
            assetsBuilder: assetsBuilder
        )
        alert.apply(
            configuration: configuration.alert,
            assetsBuilder: assetsBuilder
        )
        minimizedBubble.apply(
            configuration: configuration.bubble,
            assetsBuilder: assetsBuilder
        )
        chat.apply(
            configuration: configuration.chatScreen,
            assetsBuilder: assetsBuilder
        )
        visitorCode.apply(
            configuration: configuration.callVisualizer?.visitorCode,
            assetBuilder: assetsBuilder
        )
        secureConversationsWelcome.apply(
            configuration: configuration.secureMessagingWelcomeScreen,
            assetsBuilder: assetsBuilder
        )
        secureConversationsConfirmation.apply(
            configuration: configuration.secureMessagingConfirmationScreen,
            assetsBuilder: assetsBuilder
        )
        snackBar.apply(
            configuration: configuration.snackBar,
            assetsBuilder: assetsBuilder
        )
        webView.apply(
            configuration: configuration.webBrowserScreen,
            assetsBuilder: assetsBuilder
        )
        entryWidget.apply(
            configuration: configuration.entryWidget,
            assetsBuilder: assetsBuilder
        )
        if configuration.isWhiteLabel ?? false {
            showsPoweredBy = false
        }
    }
}
