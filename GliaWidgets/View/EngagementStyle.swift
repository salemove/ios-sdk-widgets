import UIKit

public class EngagementStyle {
    public var header: HeaderStyle
    public var queue: QueueStyle
    public var backgroundColor: UIColor
    public var endButton: ActionButtonStyle
    public var preferredStatusBarStyle: UIStatusBarStyle

    public init(header: HeaderStyle,
                queue: QueueStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle) {
        self.header = header
        self.queue = queue
        self.backgroundColor = backgroundColor
        self.endButton = endButton
        self.preferredStatusBarStyle = preferredStatusBarStyle
    }
}
