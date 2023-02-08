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
    public lazy var chat: ChatStyle = { return chatStyle }()

    /// Call view style.
    public lazy var call: CallStyle = { return callStyle }()

    /// Secure conversations welcome style.
    public lazy var secureConversationsWelcome: SecureConversations.WelcomeStyle = {
        return secureConversationsWelcomeStyle
    }()

    /// Alert view style.
    public lazy var alert: AlertStyle = { return alertStyle }()

    /// Configurations for the alerts.
    public lazy var alertConfiguration: AlertConfiguration = { return alertConfigurationStyle }()

    /// Style of the minimized bubble.
    public lazy var minimizedBubble: BubbleStyle = { return minimizedBubbleStyle }()

    /// Survey view style.
    public lazy var survey: SurveyStyle = .default(
        color: color,
        font: font,
        alertStyle: alert
    )

    /// Call Visualizer Visitor Code view style.
    public lazy var visitorCode: VisitorCodeStyle = { return visitorCodeStyle }()

    /// Call Visualizer Screen Sharing View style.
    public lazy var screenSharing: ScreenSharingViewStyle = { return screenSharingStyle }()

    /// Controls the visibility of the "Powered by" text and image.
    public var showsPoweredBy: Bool

    /// Initilizes the theme with base color and font style.
    ///
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

    /// Apply remote configuration
    func applyRemoteConfiguration(
        _ config: RemoteConfiguration,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
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
    }
}
