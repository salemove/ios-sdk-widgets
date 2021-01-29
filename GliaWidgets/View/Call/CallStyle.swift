import UIKit

public class CallStyle: EngagementStyle {
    public var audioTitle: String
    public var videoTitle: String
    public var buttonBar: CallButtonBarStyle

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle,
                audioTitle: String,
                videoTitle: String,
                buttonBar: CallButtonBarStyle) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
        self.buttonBar = buttonBar
        super.init(header: header,
                   connect: connect,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
