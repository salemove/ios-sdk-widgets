import UIKit

/// Style of the call view.
public class CallStyle: EngagementStyle {
    /// Title for the audio call.
    public var audioTitle: String

    /// Title for the video call.
    public var videoTitle: String

    /// Back button style in the header.
    public var backButton: HeaderButtonStyle

    /// Close button style in the header.
    public var closeButton: HeaderButtonStyle

    /// A text to display operator's name. Include `{operatorName}` template parameter in the string to display operator's name.
    public var operatorName: String

    /// Font of the operator's name text.
    public var operatorNameFont: UIFont

    /// Color of the operator's name text.
    public var operatorNameColor: UIColor

    /// Font of the call duration text.
    public var durationFont: UIFont

    /// Color of the call duration text.
    public var durationColor: UIColor

    /// The text shown in the top section of the view.
    public var topText: String

    /// Font of the top text.
    public var topTextFont: UIFont

    /// Color of the top text.
    public var topTextColor: UIColor

    /// The text shown in the bottom section of the view.
    public var bottomText: String

    /// Font of the bottom text.
    public var bottomTextFont: UIFont

    /// Color of the bottom text.
    public var bottomTextColor: UIColor

    /// Style of the call view bottom button bar (with buttons like "Chat", "Video", "Mute", "Speaker" and "Minimize").
    public var buttonBar: CallButtonBarStyle

    ///
    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - endButton: Style of the engagement ending button.
    ///   - endScreenShareButton: Style of the screen sharing ending button.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///   - audioTitle: Title for audio call.
    ///   - videoTitle: Title for video call.
    ///   - backButton: Back button style in the header.
    ///   - closeButton: Close button style in the header.
    ///   - operatorName: A text to display operator's name. Include `{operatorName}` template parameter in the string to display operator's name.
    ///   - operatorNameFont: Font of the operator's name text.
    ///   - operatorNameColor: Color of the operator's name text.
    ///   - durationFont: Font of the call duration text.
    ///   - durationColor: Color of the call duration text.
    ///   - topText: The text shown in the top section of the view.
    ///   - topTextFont: Font of the top text.
    ///   - topTextColor: Color of the top text.
    ///   - bottomText: The text shown in the bottom section of the view.
    ///   - bottomTextFont: Font of the bottom text.
    ///   - bottomTextColor: Color of the bottom text.
    ///   - buttonBar: Style of the button bar.
    ///
    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: UIColor,
        endButton: ActionButtonStyle,
        endScreenShareButton: HeaderButtonStyle,
        preferredStatusBarStyle: UIStatusBarStyle,
        audioTitle: String,
        videoTitle: String,
        backButton: HeaderButtonStyle,
        closeButton: HeaderButtonStyle,
        operatorName: String,
        operatorNameFont: UIFont,
        operatorNameColor: UIColor,
        durationFont: UIFont,
        durationColor: UIColor,
        topText: String,
        topTextFont: UIFont,
        topTextColor: UIColor,
        bottomText: String,
        bottomTextFont: UIFont,
        bottomTextColor: UIColor,
        buttonBar: CallButtonBarStyle
    ) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
        self.backButton = backButton
        self.closeButton = closeButton
        self.operatorName = operatorName
        self.operatorNameFont = operatorNameFont
        self.operatorNameColor = operatorNameColor
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.topText = topText
        self.topTextFont = topTextFont
        self.topTextColor = topTextColor
        self.bottomText = bottomText
        self.bottomTextFont = bottomTextFont
        self.bottomTextColor = bottomTextColor
        self.buttonBar = buttonBar
        super.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton,
            preferredStatusBarStyle: preferredStatusBarStyle
        )
    }
}
