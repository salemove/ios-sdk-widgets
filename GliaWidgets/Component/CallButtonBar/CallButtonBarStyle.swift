/// Style of the call view bottom button bar (with buttons like "Chat", "Video", "Mute", "Speaker" and "Minimize").
public struct CallButtonBarStyle {
    /// Style of chat button.
    public var chatButton: CallButtonStyle

    /// Style of video button.
    public var videoButton: CallButtonStyle

    /// Style of mute button.
    public var muteButton: CallButtonStyle

    /// Style of speaker button.
    public var speakerButton: CallButtonStyle

    /// Style of minimize button.
    public var minimizeButton: CallButtonStyle

    /// Style of the badge shown on a chat button that holds the number of unread chat messages.
    public var badge: BadgeStyle

    /// Apply button bar from remote configuration
    mutating func applyBarConfiguration(
        _ bar: RemoteConfiguration.ButtonBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        minimizeButton.applyBarButtonConfig(
            button: bar?.minimizeButton,
            assetsBuilder: assetsBuilder
        )
        chatButton.applyBarButtonConfig(
            button: bar?.chatButton,
            assetsBuilder: assetsBuilder
        )
        videoButton.applyBarButtonConfig(
            button: bar?.videoButton,
            assetsBuilder: assetsBuilder
        )
        muteButton.applyBarButtonConfig(
            button: bar?.muteButton,
            assetsBuilder: assetsBuilder
        )
        speakerButton.applyBarButtonConfig(
            button: bar?.speakerButton,
            assetsBuilder: assetsBuilder
        )
        badge.apply(
            configuration: bar?.badge,
            assetsBuilder: assetsBuilder
        )
    }
}
