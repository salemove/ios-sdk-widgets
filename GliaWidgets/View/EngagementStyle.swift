import UIKit

public class EngagementStyle {
    public var header: HeaderStyle
    public var connect: ConnectStyle
    public var backgroundColor: UIColor
    public var endButton: ActionButtonStyle
    public var preferredStatusBarStyle: UIStatusBarStyle

    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle) {
        self.header = header
        self.connect = connect
        self.backgroundColor = backgroundColor
        self.endButton = endButton
        self.preferredStatusBarStyle = preferredStatusBarStyle
    }
}
