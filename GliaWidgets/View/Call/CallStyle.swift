import UIKit

/// Style of the call view.
public class CallStyle: EngagementStyle {
    /// Title for the audio call.
    public var audioTitle: String

    /// Title for the video call.
    public var videoTitle: String

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

    /// Style of the call view when the visitor is put on hold.
    public var onHoldStyle: OnHoldStyle

	/// Accessiblity properties for CallStyle.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///   - audioTitle: Title for audio call.
    ///   - videoTitle: Title for video call.
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
    ///   - onHoldStyle: Style of the call view when the visitor is put on hold.
    ///   - accessibility: Accessiblity properties for CallStyle.
	///
    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: UIColor,
        preferredStatusBarStyle: UIStatusBarStyle,
        audioTitle: String,
        videoTitle: String,
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
        buttonBar: CallButtonBarStyle,
        onHoldStyle: OnHoldStyle,
        accessibility: Accessibility
    ) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
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
        self.onHoldStyle = onHoldStyle
        self.accessibility = accessibility
        super.init(
            header: header,
            connect: connect,
            backgroundColor: backgroundColor,
            preferredStatusBarStyle: preferredStatusBarStyle
        )
    }
}

extension CallStyle {
    public struct OnHoldStyle {
        /// The text shown in the top section of the call view when visitor is put on hold
        public var onHoldText: String

        /// The text shown in the bottom section of the call view when visitor is put on hold
        public var descriptionText: String

        /// The text shown in the local video stream view when visitor is put on hold
        public var localVideoStreamLabelText: String

        /// The text font for the label in the local video stream view when visitor is put on hold
        public var localVideoStreamLabelFont: UIFont

        /// The text color for the label in the local video stream view when visitor is put on hold
        public var localVideoStreamLabelColor: UIColor

        ///
        /// - Parameters:
        ///   - topText: The text shown in the top section of the call view when visitor is put on hold
        ///   - bottomText: The text shown in the bottom section of the call view when visitor is put on hold
        ///   - localVideoStreamText: The text shown in the local video stream view when visitor is put on hold
        ///   - localVideoStreamLabelFont: The text font for the label in the local video stream view when visitor is put on hold
        ///   - localVideoStreamLabelColor: The text color for the label in the local video stream view when visitor is put on hold
        ///
        public init(
            onHoldText: String,
            descriptionText: String,
            localVideoStreamLabelText: String,
            localVideoStreamLabelFont: UIFont,
            localVideoStreamLabelColor: UIColor
        ) {
            self.onHoldText = onHoldText
            self.descriptionText = descriptionText
            self.localVideoStreamLabelText = localVideoStreamLabelText
            self.localVideoStreamLabelFont = localVideoStreamLabelFont
            self.localVideoStreamLabelColor = localVideoStreamLabelColor
        }
    }
}
