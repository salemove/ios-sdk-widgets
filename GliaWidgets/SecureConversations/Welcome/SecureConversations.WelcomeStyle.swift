import Foundation
import UIKit

extension SecureConversations {
    /// Theme of the secure conversations welcome view.
    public struct WelcomeStyle: Equatable {
        /// Style of the view's header (navigation bar area).
        public var header: HeaderStyle

        /// Title shown in the header.
        public var headerTitle: String

        /// Style for title shown in the welcome area.
        public var welcomeTitleStyle: TitleStyle

        /// Style for title icon image.
        public var titleImageStyle: TitleImageStyle

        /// Style for description showm in the welcome area.
        public var welcomeSubtitleStyle: SubtitleStyle

        /// Style for button to check messages.
        public var checkMessagesButtonStyle: CheckMessagesButtonStyle

        /// Style for message text view title.
        public var messageTitleStyle: MessageTitleStyle?

        /// Style for message text view.
        public var messageTextViewStyle: MessageTextViewStyle

        /// Style for send message button.
        public var sendButtonStyle: SendButtonStyle

        /// Style for message warning section.
        public var messageWarningStyle: MessageWarningStyle

        /// Style for attachment button.
        public var filePickerButtonStyle: FilePickerButtonStyle

        /// Style for list of message attachments.
        public var attachmentListStyle: MessageCenterFileUploadListStyle

        /// Style of the list that contains the chat attachment sources. Appears in the media upload menu popover in the message input area in welcome screen.
        public var pickMediaStyle: AttachmentSourceListStyle

        /// View's background color.
        public var backgroundColor: UIColor

        ///   - header: Style of the view's header (navigation bar area).
        ///   - headerTitle: Title shown in the header.
        ///   - welcomeTitleStyle: Style for title shown in the welcome area.
        ///   - welcomeSubtitleStyle: Style for description showm in the welcome area.
        ///   - checkMessagesButtonStyle: Style for button to check messages.
        ///   - messageTitleStyle: Style for message text view title.
        ///   - messageTextViewStyle: Style for message text view.
        ///   - sendButtonStyle: Style for send message button.
        ///   - messageWarningStyle: Style for message warning section.
        ///   - filePickerButtonStyle: Style for file picker button.
        ///   - attachmentListStyle: Style for list of message attachments.
        ///   - pickMediaStyle: Style of the list that contains the chat attachment sources. Appears in the media upload menu popover in the message input area in welcome screen.
        ///   - backgroundColor: Welcome area's view background color.
        public init(
            header: HeaderStyle,
            headerTitle: String,
            welcomeTitleStyle: TitleStyle,
            titleImageStyle: TitleImageStyle,
            welcomeSubtitleStyle: SubtitleStyle,
            checkMessagesButtonStyle: CheckMessagesButtonStyle,
            messageTitleStyle: MessageTitleStyle,
            messageTextViewStyle: MessageTextViewStyle,
            sendButtonStyle: SendButtonStyle,
            messageWarningStyle: MessageWarningStyle,
            filePickerButtonStyle: FilePickerButtonStyle,
            attachmentListStyle: MessageCenterFileUploadListStyle,
            pickMediaStyle: AttachmentSourceListStyle,
            backgroundColor: UIColor
        ) {
            self.header = header
            self.headerTitle = headerTitle
            self.welcomeTitleStyle = welcomeTitleStyle
            self.welcomeSubtitleStyle = welcomeSubtitleStyle
            self.checkMessagesButtonStyle = checkMessagesButtonStyle
            self.messageTitleStyle = messageTitleStyle
            self.messageTextViewStyle = messageTextViewStyle
            self.sendButtonStyle = sendButtonStyle
            self.messageWarningStyle = messageWarningStyle
            self.filePickerButtonStyle = filePickerButtonStyle
            self.backgroundColor = backgroundColor
            self.titleImageStyle = titleImageStyle
            self.attachmentListStyle = attachmentListStyle
            self.pickMediaStyle = pickMediaStyle
        }
    }
}
