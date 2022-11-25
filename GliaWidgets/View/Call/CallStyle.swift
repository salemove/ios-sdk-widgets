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

    /// Text style of the operator's name text.
    public var operatorNameTextStyle: UIFont.TextStyle

    /// Font of the call duration text.
    public var durationFont: UIFont

    /// Color of the call duration text.
    public var durationColor: UIColor

    /// Text style of the duration text.
    public var durationTextStyle: UIFont.TextStyle

    /// The text shown in the top section of the view.
    public var topText: String

    /// Font of the top text.
    public var topTextFont: UIFont

    /// Color of the top text.
    public var topTextColor: UIColor

    /// Text style of the top text.
    public var topTextStyle: UIFont.TextStyle

    /// The text shown in the bottom section of the view.
    public var bottomText: String

    /// Font of the bottom text.
    public var bottomTextFont: UIFont

    /// Color of the bottom text.
    public var bottomTextColor: UIColor

    /// Text style of the bottom text.
    public var bottomTextStyle: UIFont.TextStyle

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
    ///   - operatorNameTextStyle: Text style of the operator's name text.
    ///   - durationFont: Font of the call duration text.
    ///   - durationColor: Color of the call duration text.
    ///   - durationTextStyle: Text style of the duration text.
    ///   - topText: The text shown in the top section of the view.
    ///   - topTextFont: Font of the top text.
    ///   - topTextColor: Color of the top text.
    ///   - topTextStyle: Text style of the top text.
    ///   - bottomText: The text shown in the bottom section of the view.
    ///   - bottomTextFont: Font of the bottom text.
    ///   - bottomTextColor: Color of the bottom text.
    ///   - bottomTextStyle: Text style of the bottom text.
    ///   - buttonBar: Style of the button bar.
    ///   - onHoldStyle: Style of the call view when the visitor is put on hold.
    ///   - accessibility: Accessiblity properties for CallStyle.
    ///
    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: ColorType,
        preferredStatusBarStyle: UIStatusBarStyle,
        audioTitle: String,
        videoTitle: String,
        operatorName: String,
        operatorNameFont: UIFont,
        operatorNameColor: UIColor,
        operatorNameTextStyle: UIFont.TextStyle = .title1,
        durationFont: UIFont,
        durationColor: UIColor,
        durationTextStyle: UIFont.TextStyle = .body,
        topText: String,
        topTextFont: UIFont,
        topTextColor: UIColor,
        topTextStyle: UIFont.TextStyle = .footnote,
        bottomText: String,
        bottomTextFont: UIFont,
        bottomTextColor: UIColor,
        bottomTextStyle: UIFont.TextStyle = .body,
        buttonBar: CallButtonBarStyle,
        onHoldStyle: OnHoldStyle,
        accessibility: Accessibility = .unsupported
    ) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
        self.operatorName = operatorName
        self.operatorNameFont = operatorNameFont
        self.operatorNameColor = operatorNameColor
        self.operatorNameTextStyle = operatorNameTextStyle
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.durationTextStyle = durationTextStyle
        self.topText = topText
        self.topTextFont = topTextFont
        self.topTextColor = topTextColor
        self.topTextStyle = topTextStyle
        self.bottomText = bottomText
        self.bottomTextFont = bottomTextFont
        self.bottomTextColor = bottomTextColor
        self.bottomTextStyle = bottomTextStyle
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
    func apply(
        configuration: RemoteConfiguration.Call?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyBarConfiguration(
            configuration?.buttonBar,
            assetsBuilder: assetsBuilder
        )
        applyBackgroundConfiguration(configuration?.background)
        applyOperatorConfiguration(
            configuration?.callOperator,
            assetsBuilder: assetsBuilder
        )
        header.apply(
            configuration: configuration?.header,
            assetsBuilder: assetsBuilder
        )
        applyDurationConfiguration(
            configuration?.duration,
            assetsBuilder: assetsBuilder
        )
        applyTopTextConfiguration(
            configuration?.topText,
            assetsBuilder: assetsBuilder
        )
        applyBottomTextConfiguration(
            configuration?.bottomText,
            assetsBuilder: assetsBuilder
        )

        connect.apply(
            configuration: configuration?.connect,
            assetsBuilder: assetsBuilder
        )
    }

    /// Apply bottomText from remote configuration
    private func applyBottomTextConfiguration(
        _ bottomText: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {

        bottomText?.alignment.unwrap { _ in
            // The logic for bottomText alignment has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(bottomText?.font),
            textStyle: bottomTextStyle
        ).unwrap { bottomTextFont = $0 }

        bottomText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { bottomTextColor = $0 }
    }

    /// Apply topText from remote configuration
    private func applyTopTextConfiguration(
        _ topText: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {

        topText?.alignment.unwrap { _ in
            // The logic for topText alignment has not been implemented
        }

        topText?.background.unwrap { _ in
            // The logic for topText background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(topText?.font),
            textStyle: topTextStyle
        ).unwrap { topTextFont = $0 }

        topText?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { topTextColor = $0 }
    }

    /// Apply duration from remote configuration
    private func applyDurationConfiguration(
        _ duration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {

        duration?.alignment.unwrap { _ in
            // The logic for duration alignment has not been implemented
        }

        duration?.background.unwrap { _ in
            // The logic for duration background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(duration?.font),
            textStyle: durationTextStyle
        ).unwrap { durationFont = $0 }

        duration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { durationColor = $0 }
    }

    /// Apply operator from remote configuration
    private func applyOperatorConfiguration(
        _ callOperator: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        callOperator?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { self.operatorNameColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(callOperator?.font),
            textStyle: operatorNameTextStyle
        ).unwrap { operatorNameFont = $0 }
    }

    /// Apply background from remote configuration
    private func applyBackgroundConfiguration(_ background: RemoteConfiguration.Layer?) {
        background?.color.unwrap {
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

    /// Apply bar buttons from remote configuration
    private func applyBarConfiguration(
        _ bar: RemoteConfiguration.ButtonBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        buttonBar.applyBarConfiguration(
            bar,
            assetsBuilder: assetsBuilder
        )
    }
}
