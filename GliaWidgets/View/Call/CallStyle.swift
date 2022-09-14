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
        accessibility: Accessibility = .unsupported
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

    /// Apply call configuration from remote configuration
    public func applyCallConfiguration(_ call: RemoteConfiguration.Call?) {
        applyBarConfiguration(call?.buttonBar)
        applyBackgroundConfiguration(call?.background)
        applyOperatorConfiguration(call?.callOperator)
        applyHeaderConfiguration(call?.header)
        applyEndButtonConfiguration(call?.endButton)
        applyDurationConfiguration(call?.duration)
        applyTopTextConfiguration(call?.topText)
        applyBottomTextConfiguration(call?.bottomText)
    }

    /// Apply bottomText from remote configuration
    private func applyBottomTextConfiguration(_ bottomText: RemoteConfiguration.Text?) {

        bottomText?.alignment.map { _ in

        /// The logic for bottomText alignment has not been implemented

        }

        bottomText?.background?.type.map { _ in

        /// The logic for bottomText background has not been implemented

        }

        if let fontSize = bottomText?.font?.size, let fontStyle = bottomText?.font?.style {
            switch fontStyle {
            case .bold:
                self.bottomTextFont = UIFont.boldSystemFont(ofSize: fontSize)
            case .italic:
                self.bottomTextFont = UIFont.italicSystemFont(ofSize: fontSize)
            case .regular:
                self.bottomTextFont = UIFont.systemFont(ofSize: fontSize)
            case .thin:
                self.bottomTextFont = UIFont.systemFont(ofSize: fontSize, weight: .thin)
            }
        }

        bottomText?.foreground?.value.map { colors in
            self.bottomTextColor = UIColor.init(hex: colors[0])
        }
    }

    /// Apply topText from remote configuration
    private func applyTopTextConfiguration(_ topText: RemoteConfiguration.Text?) {

        topText?.alignment.map { _ in

        /// The logic for topText alignment has not been implemented

        }

        topText?.background?.type.map { _ in

        /// The logic for topText background has not been implemented

        }

        if let fontSize = topText?.font?.size, let fontStyle = topText?.font?.style {
            switch fontStyle {
            case .bold:
                self.topTextFont = UIFont.boldSystemFont(ofSize: fontSize)
            case .italic:
                self.topTextFont = UIFont.italicSystemFont(ofSize: fontSize)
            case .regular:
                self.topTextFont = UIFont.systemFont(ofSize: fontSize)
            case .thin:
                self.topTextFont = UIFont.systemFont(ofSize: fontSize, weight: .thin)
            }
        }

        topText?.foreground?.value.map { colors in
            self.topTextColor = UIColor.init(hex: colors[0])
        }
    }

    /// Apply duration from remote configuration
    private func applyDurationConfiguration(_ duration: RemoteConfiguration.Text?) {

        duration?.alignment.map { _ in

        /// The logic for duration alignment has not been implemented

        }

        duration?.background?.type.map { _ in

        /// The logic for duration background has not been implemented

        }

        if let fontSize = duration?.font?.size, let fontStyle = duration?.font?.style {
            switch fontStyle {
            case .bold:
                self.durationFont = UIFont.boldSystemFont(ofSize: fontSize)
            case .italic:
                self.durationFont = UIFont.italicSystemFont(ofSize: fontSize)
            case .regular:
                self.durationFont = UIFont.systemFont(ofSize: fontSize)
            case .thin:
                self.durationFont = UIFont.systemFont(ofSize: fontSize, weight: .thin)
            }
        }

        duration?.foreground?.value.map { colors in
            self.durationColor = UIColor.init(hex: colors[0])
        }
    }

    /// Apply end button from remote configuration
    private func applyEndButtonConfiguration(_ endButton: RemoteConfiguration.Button?) {
        endButton?.background?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                endButton?.background?.value.map { colors in
                    header.endButton.backgroundColor = UIColor.init(hex: colors[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        endButton?.text?.alignment.map { _ in

        /// The logic for duration alignment has not been implemented

        }

        endButton?.text?.background?.type.map { _ in

        /// The logic for duration background has not been implemented

        }

        if let fontSize = endButton?.text?.font?.size, let fontStyle = endButton?.text?.font?.style {
            switch fontStyle {
            case .bold:
                header.endButton.titleFont = UIFont.boldSystemFont(ofSize: fontSize)
            case .italic:
                header.endButton.titleFont = UIFont.italicSystemFont(ofSize: fontSize)
            case .regular:
                header.endButton.titleFont = UIFont.systemFont(ofSize: fontSize)
            case .thin:
                header.endButton.titleFont = UIFont.systemFont(ofSize: fontSize, weight: .thin)
            }
        }

        endButton?.text?.foreground?.value.map { colors in
            header.endButton.titleColor = UIColor.init(hex: colors[0])
        }
    }

    /// Apply header from remote configuration
    private func applyHeaderConfiguration(_ header: RemoteConfiguration.Header?) {
        header?.background?.border.map { _ in

        /// The logic for header border has not been implemented

        }

        header?.background?.borderWidth.map { _ in

        /// The logic for header borderWidth has not been implemented

        }

        header?.background?.cornerRadius.map { _ in

        /// The logic for header cornerRadius has not been implemented

        }

        header?.background?.color?.value.map { foreground in
            self.header.titleColor = UIColor.init(hex: foreground[0])
        }

        header?.text?.alignment.map { _ in

        /// The logic for title alignment has not been implemented

        }

        header?.text?.background.map { _ in

        /// The logic for title background has not been implemented

        }

        if let titleFontSize = header?.text?.font?.size, let titleFontStyle = header?.text?.font?.style {
            switch titleFontStyle {
            case .bold:
                self.header.titleFont = UIFont.boldSystemFont(ofSize: titleFontSize)
            case .italic:
                self.header.titleFont = UIFont.italicSystemFont(ofSize: titleFontSize)
            case .regular:
                self.header.titleFont = UIFont.systemFont(ofSize: titleFontSize)
            case .thin:
                self.header.titleFont = UIFont.systemFont(ofSize: titleFontSize, weight: .thin)
            }
        }

        header?.text?.foreground?.value.map { titleForeground in
            self.header.titleColor = UIColor.init(hex: titleForeground[0])
        }
    }

    /// Apply operator from remote configuration
    private func applyOperatorConfiguration(_ callOperator: RemoteConfiguration.Text?) {
        callOperator?.foreground?.value.map { colors in
            self.operatorNameColor = UIColor.init(hex: colors[0])
        }

        if let fontSize = callOperator?.font?.size, let fontStyle = callOperator?.font?.style {
            switch fontStyle {
            case .bold:
                self.operatorNameFont = UIFont.boldSystemFont(ofSize: fontSize)
            case .italic:
                self.operatorNameFont = UIFont.italicSystemFont(ofSize: fontSize)
            case .regular:
                self.operatorNameFont = UIFont.systemFont(ofSize: fontSize)
            case .thin:
                self.operatorNameFont = UIFont.systemFont(ofSize: fontSize, weight: .thin)
            }
        }
    }

    /// Apply background from remote configuration
    private func applyBackgroundConfiguration(_ background: RemoteConfiguration.Layer?) {
        background?.color?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                background?.color?.value.map { colors in
                    self.backgroundColor = UIColor.init(hex: colors[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented yet

                break
            }
        }
    }

    /// Apply bar buttons from remote configuration
    private func applyBarConfiguration(_ bar: RemoteConfiguration.ButtonBar?) {
        buttonBar.applyBarConfiguration(bar)
    }
}
