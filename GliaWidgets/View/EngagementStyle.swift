import UIKit

/// Base style for engagement views.
public class EngagementStyle {
    /// Style of the view's header (navigation bar area).
    public var header: HeaderStyle

    /// Styles for different engagement connection states.
    public var connect: ConnectStyle

    /// View's background color.
    public var backgroundColor: UIColor

    /// Style of the engagement ending button.
    public var endButton: ActionButtonStyle

    /// Style of the screen sharing ending button.
    public var endScreenShareButton: HeaderButtonStyle

    /// Preferred style of the status bar.
    public var preferredStatusBarStyle: UIStatusBarStyle

    ///
    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - endButton: Style of the engagement ending button.
    ///   - endScreenShareButton: Style of the screen sharing ending button.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///
    public init(header: HeaderStyle,
                connect: ConnectStyle,
                backgroundColor: UIColor,
                endButton: ActionButtonStyle,
                endScreenShareButton: HeaderButtonStyle,
                preferredStatusBarStyle: UIStatusBarStyle) {
        self.header = header
        self.connect = connect
        self.backgroundColor = backgroundColor
        self.endButton = endButton
        self.endScreenShareButton = endScreenShareButton
        self.preferredStatusBarStyle = preferredStatusBarStyle
    }
}
