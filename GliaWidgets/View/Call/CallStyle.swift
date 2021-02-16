import UIKit

public class CallStyle: EngagementStyle {
    public var audioTitle: String
    public var videoTitle: String
    public var backButton: HeaderButtonStyle
    public var closeButton: HeaderButtonStyle
    public var operatorName: String
    public var operatorNameFont: UIFont
    public var operatorNameColor: UIColor
    public var durationFont: UIFont
    public var durationColor: UIColor
    public var topText: String
    public var topTextFont: UIFont
    public var topTextColor: UIColor
    public var bottomText: String
    public var bottomTextFont: UIFont
    public var bottomTextColor: UIColor
    public var buttonBar: CallButtonBarStyle

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
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
                buttonBar: CallButtonBarStyle) {
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
        super.init(header: header,
                   connect: connect,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
