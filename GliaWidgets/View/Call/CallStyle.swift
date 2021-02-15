import UIKit

public class CallStyle: EngagementStyle {
    public var audioTitle: String
    public var videoTitle: String
    public var operatorName: String
    public var operatorNameFont: UIFont
    public var operatorNameColor: UIColor
    public var durationFont: UIFont
    public var durationColor: UIColor
    public var infoText: String
    public var infoTextFont: UIFont
    public var infoTextColor: UIColor
    public var buttonBar: CallButtonBarStyle

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle,
                audioTitle: String,
                videoTitle: String,
                operatorName: String,
                operatorNameFont: UIFont,
                operatorNameColor: UIColor,
                durationFont: UIFont,
                durationColor: UIColor,
                infoText: String,
                infoTextFont: UIFont,
                infoTextColor: UIColor,
                buttonBar: CallButtonBarStyle) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
        self.operatorName = operatorName
        self.operatorNameFont = operatorNameFont
        self.operatorNameColor = operatorNameColor
        self.durationFont = durationFont
        self.durationColor = durationColor
        self.infoText = infoText
        self.infoText = infoText
        self.infoTextFont = infoTextFont
        self.infoTextColor = infoTextColor
        self.buttonBar = buttonBar
        super.init(header: header,
                   connect: connect,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
