import UIKit

/// Base style for engagement views.
public class EngagementStyle: Equatable {
    /// Style of the view's header (navigation bar area).
    public var header: HeaderStyle

    /// Styles for different engagement connection states.
    public var connect: ConnectStyle

    /// View's background color.
    public var backgroundColor: ColorType

    /// View's preferred status bar style.
    public var preferredStatusBarStyle: UIStatusBarStyle

    /// - Parameters:
    ///   - header: Style of the view's header (navigation bar area).
    ///   - connect: Styles for different engagement connection states.
    ///   - backgroundColor: View's background color.
    ///   - preferredStatusBarStyle: Preferred style of the status bar.
    ///
    public init(
        header: HeaderStyle,
        connect: ConnectStyle,
        backgroundColor: ColorType,
        preferredStatusBarStyle: UIStatusBarStyle
    ) {
        self.header = header
        self.connect = connect
        self.backgroundColor = backgroundColor
        self.preferredStatusBarStyle = preferredStatusBarStyle
    }
}
