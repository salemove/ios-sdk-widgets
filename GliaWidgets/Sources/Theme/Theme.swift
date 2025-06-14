import UIKit

/// Describes Glia's UI appearance.
///
/// A theme can be created with a `ThemeColorStyle` and `ThemeFontStyle`.
/// After creation, theme's appearance can be customized through its customizable properties.
///
/// ## Customizable properties:
///   - `color`:  Base colors used in theme.
///   - `font`:  Base font styles used in theme.
///   - `chat`:  Chat view style.
///   - `call`:  Call view style.
///   - `alert`:  Alert view style.
///   - `alertConfiguration`:  Configurations for alerts.
///   - `minimizedBubble`:  Style of the minimized bubble.
///   - `showsPoweredBy`:  Controls the visibility of the "Powered by" text and image.
///
public class Theme {
    /// Base colors used in the theme.
    public var color: ThemeColor

    /// Base font styles used in the theme.
    public var font: ThemeFont

    /// Chat view style.
    public lazy var chat: ChatStyle = { chatStyle }()

    /// Call view style.
    public lazy var call: CallStyle = { callStyle }()

    /// Secure conversations welcome style.
    public lazy var secureConversationsWelcome: SecureConversations.WelcomeStyle = {
        secureConversationsWelcomeStyle
    }()

    /// Alert view style.
    public lazy var alert: AlertStyle = { alertStyle }()

    /// Configurations for the alerts.
    public lazy var alertConfiguration: AlertConfiguration = { alertConfigurationStyle }()

    /// Style of the minimized bubble.
    public lazy var minimizedBubble: BubbleStyle = { minimizedBubbleStyle }()

    /// Survey view style.
    public lazy var survey: SurveyStyle = .default(
        color: color,
        font: font,
        alertStyle: alert
    )

    /// Call Visualizer Visitor Code view style.
    public lazy var visitorCode: VisitorCodeStyle = { visitorCodeStyle }()

    /// Call Visualizer Screen Sharing View style.
    public lazy var screenSharing: ScreenSharingViewStyle = { screenSharingStyle }()

    // Confirmation Screen in Secure Conversation flow style.
    public lazy var secureConversationsConfirmation: SecureConversations.ConfirmationStyle = defaultSecureConversationsConfirmationStyle

    /// Controls the visibility of the "Powered by" text and image.
    @available(*, deprecated, message: "Replaced by RemoteConfiguration.isWhiteLabelApp")
    public var showsPoweredBy: Bool

    /// Snack bar View style.
    public lazy var snackBar: SnackBarStyle = { snackBarStyle }()

    /// Inverted snack bar View style.
    public lazy var invertedSnackBar: SnackBarStyle = { invertedSnackBarStyle }()

    /// Chat view style.
    public lazy var webView: WebViewStyle = { webViewStyle }()

    /// EntryWidget style.
    public lazy var entryWidget: EntryWidgetStyle = { entryWidgetStyle }()

    /// Initilizes the theme with base color and font style.
    /// - Parameters:
    ///   - colorStyle: Color style for the theme. Defaults to `default` style.
    ///   - fontStyle: Font style for the theme. Defaults to `default` style.
    ///   - showsPoweredBy: Controls the visibility of the "Powered by" text and image.
    ///
    public init(
        colorStyle: ThemeColorStyle = .default,
        fontStyle: ThemeFontStyle = .default,
        showsPoweredBy: Bool = true
    ) {
        self.color = colorStyle.color
        self.font = fontStyle.font
        self.showsPoweredBy = showsPoweredBy
    }

    // swiftlint:disable function_body_length
    convenience init(
        uiConfig config: RemoteConfiguration,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        self.init(
            colorStyle: .custom(
                .init(
                    primary: config.globalColors?.primary.map { UIColor(hex: $0) },
                    secondary: config.globalColors?.secondary.map { UIColor(hex: $0) },
                    baseNormal: config.globalColors?.baseNormal.map { UIColor(hex: $0) },
                    baseLight: config.globalColors?.baseLight.map { UIColor(hex: $0) },
                    baseDark: config.globalColors?.baseDark.map { UIColor(hex: $0) },
                    baseShade: config.globalColors?.baseShade.map { UIColor(hex: $0) },
                    systemNegative: config.globalColors?.systemNegative.map { UIColor(hex: $0) },
                    baseNeutral: config.globalColors?.baseNeutral.map { UIColor(hex: $0) }
                )
            )
        )

        call.apply(
            configuration: config.callScreen,
            assetsBuilder: assetsBuilder
        )
        survey.apply(
            configuration: config.surveyScreen,
            assetsBuilder: assetsBuilder
        )
        alert.apply(
            configuration: config.alert,
            assetsBuilder: assetsBuilder
        )
        minimizedBubble.apply(
            configuration: config.bubble,
            assetsBuilder: assetsBuilder
        )
        chat.apply(
            configuration: config.chatScreen,
            assetsBuilder: assetsBuilder
        )
        visitorCode.apply(
            configuration: config.callVisualizer?.visitorCode,
            assetBuilder: assetsBuilder
        )
        screenSharing.apply(
            configuration: config.callVisualizer?.screenSharing,
            assetBuilder: assetsBuilder
        )
        secureConversationsWelcome.apply(
            configuration: config.secureMessagingWelcomeScreen,
            assetsBuilder: assetsBuilder
        )
        secureConversationsConfirmation.apply(
            configuration: config.secureMessagingConfirmationScreen,
            assetsBuilder: assetsBuilder
        )
        snackBar.apply(
            configuration: config.snackBar,
            assetsBuilder: assetsBuilder
        )
        webView.apply(
            configuration: config.webBrowserScreen,
            assetsBuilder: assetsBuilder
        )
        entryWidget.apply(
            configuration: config.entryWidget,
            assetsBuilder: assetsBuilder
        )
    }
    // swiftlint:enable function_body_length
}
