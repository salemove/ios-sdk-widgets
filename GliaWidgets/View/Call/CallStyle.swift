import UIKit

public class CallStyle: EngagementStyle {
    public var audioTitle: String
    public var videoTitle: String
    public var operatorNameFont: UIFont
    public var operatorNameColor: UIColor
    public var durationFont: UIFont
    public var durationColor: UIColor

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle,
                audioTitle: String,
                videoTitle: String,
                operatorNameFont: UIFont,
                operatorNameColor: UIColor,
                durationFont: UIFont,
                durationColor: UIColor) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
        self.operatorNameFont = operatorNameFont
        self.operatorNameColor = operatorNameColor
        self.durationFont = durationFont
        self.durationColor = durationColor
        super.init(header: header,
                   connect: connect,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
