import Foundation
import UIKit

extension SecureConversations {
    /// Theme of the secure conversations welcome view.
    public class WelcomeStyle {
        /// Style of the view's header (navigation bar area).
        public var header: HeaderStyle

        /// Title shown in the header.
        public var title: String

        /// Title shown in the welcome area.
        public var welcomeTitle: String

        /// Description showm in the welcome area.
        public var welcomeDescription: String

        /// View's background color.
        public var backgroundColor: UIColor

        /// - Parameters:
        ///   - header: Style of the view's header (navigation bar area).
        ///   - title: Title shown in the header.
        ///   - welcomeTitle: Title shown in the welcome area.
        ///   - welcomeDescription: Description showm in the welcome area.
        ///   - backgroundColor: View's background color.
        public init(
            header: HeaderStyle,
            title: String,
            welcomeTitle: String,
            welcomeDescription: String,
            backgroundColor: UIColor
        ) {
            self.header = header
            self.title = title
            self.welcomeTitle = welcomeTitle
            self.welcomeDescription = welcomeDescription
            self.backgroundColor = backgroundColor
        }
    }
}
