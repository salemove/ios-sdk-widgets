import Foundation
import UIKit

extension SecureConversations {
    /// Theme of the secure conversations confirmation view.
    public struct ConfirmationStyle: Equatable {
        /// Style of the view's header (navigation bar area).
        public var header: HeaderStyle

        /// Title shown in the header.
        public var headerTitle: String

        /// Image shown in the confirmation screen.
        public var confirmationImage: UIImage

        /// Style for title shown in the confirmation area.
        public var titleStyle: TitleStyle

        /// Style for subtitle shown in the confirmation area.
        public var subtitleStyle: SubtitleStyle

        /// Style for button to check messages.
        public var checkMessagesButtonStyle: CheckMessagesButtonStyle

        /// View's background color
        public var backgroundColor: UIColor

        /// - Parameters:
        ///   - header: Style of the view's header (navigation bar area).
        ///   - headerTitle: Title shown in the header.
        ///   - confirmationImage: Image shown in the confirmation screen.
        ///   - titleStyle: Style for title shown in the confirmation area.
        ///   - subtitleStyle: Style for subtitle shown in the confirmation area.
        ///   - checkMessagesButtonStyle: Style for button to check messages.
        ///   - backgroundColor: View's background color
        public init(
            header: HeaderStyle,
            headerTitle: String,
            confirmationImage: UIImage,
            titleStyle: TitleStyle,
            subtitleStyle: SubtitleStyle,
            checkMessagesButtonStyle:
            CheckMessagesButtonStyle,
            backgroundColor: UIColor
        ) {
            self.header = header
            self.headerTitle = headerTitle
            self.confirmationImage = confirmationImage
            self.titleStyle = titleStyle
            self.subtitleStyle = subtitleStyle
            self.checkMessagesButtonStyle = checkMessagesButtonStyle
            self.backgroundColor = backgroundColor
        }
    }
}
