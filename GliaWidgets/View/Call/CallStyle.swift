import UIKit

public class CallStyle: EngagementStyle {
    public var audioTitle: String
    public var videoTitle: String

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle,
                audioTitle: String,
                videoTitle: String) {
        self.audioTitle = audioTitle
        self.videoTitle = videoTitle
        super.init(header: header,
                   connect: connect,
                   backgroundColor: backgroundColor,
                   endButton: endButton,
                   preferredStatusBarStyle: preferredStatusBarStyle)
    }
}
