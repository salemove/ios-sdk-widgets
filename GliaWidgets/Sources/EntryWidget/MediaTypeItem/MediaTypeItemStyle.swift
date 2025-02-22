import UIKit

extension EntryWidgetStyle {
    public struct MediaTypeItemStyle: Equatable {
        /// The title for chat media type.
        public var chatTitle: String

        /// The title for audio media type.
        public var audioTitle: String

        /// The title for video media type.
        public var videoTitle: String

        /// The title for secure messaging media type.
        public var secureMessagingTitle: String

        /// The title for call visualizer media type.
        public var callVisualizerTitle: String

        /// Font of the headline text.
        public var titleFont: UIFont

        /// Color of the headline text.
        public var titleColor: UIColor

        /// Text style of the message text.
        public var titleTextStyle: UIFont.TextStyle

        /// The subheadline (message) text for chat media type.
        public var chatMessage: String

        /// The subheadline (message) text for audio media type.
        public var audioMessage: String

        /// The subheadline (message) text for video media type.
        public var videoMessage: String

        /// The subheadline (message) text for secure messaging media type.
        public var secureMessagingMessage: String

        /// Font of the subheadline (message) text.
        public var messageFont: UIFont

        /// Color of the subheadline (message) text.
        public var messageColor: UIColor

        /// Font of the unread messages counter number.
        public var unreadMessagesCounterFont: UIFont

        /// Color of the unread messages counter number.
        public var unreadMessagesCounterColor: UIColor

        /// Color of the unread messages counter background.
        public var unreadMessagesCounterBackgroundColor: ColorType

        /// Text style of the message text.
        public var messageTextStyle: UIFont.TextStyle

        /// Color of the icon.
        public var iconColor: ColorType

        /// Background color of the view.
        public var backgroundColor: ColorType

        /// Loading style of the EntryWidget MediaType.
        public var loading: LoadingStyle

        /// Accessibility properties for EntryWidget MediaType Item.
        public var accessibility: Accessibility

        /// The ongoing core engagement message string
        public var ongoingCoreEngagementMessage: String

        /// The ongoing call visualizer message string
        public var ongoingCallVisualizerMessage: String

        /// The ongoing engagement message font
        public var ongoingEngagementMessageFont: UIFont

        /// The ongoing engagement message color
        public var ongoingEngagementMessageColor: UIColor

        /// - Parameters:
        ///   - chatTitle: Title for chat media type.
        ///   - audioTitle: Title for audio media type.
        ///   - videoTitle: Title for video media type.
        ///   - secureMessagingTitle: Title for secure messaging media type.
        ///   - titleFont: Font of the headline text.
        ///   - titleColor: Color of the headline text.
        ///   - titleTextStyle: The style of the title text.
        ///   - chatMessage: The subheadline (message) text for chat media type.
        ///   - audioMessage: The subheadline (message) text for audio media type.
        ///   - videoMessage: The subheadline (message) text for video media type.
        ///   - secureMessagingMessage: The subheadline (message) text for secure messaging media type.
        ///   - messageFont: Font of the subheadline (message) text.
        ///   - messageColor: Color of the subheadline (message) text.
        ///   - unreadMessagesCounterFont: Font of the unread messages counter number.
        ///   - unreadMessagesCounterBackgroundColor: Color of the unread messages counter background.
        ///   - messageTextStyle: The style of the title text.
        ///   - iconColor: Color of the icon.
        ///   - backgroundColor: Background color of the view.
        ///   - loading: Loading style of the EntryWidget MediaType.
        ///   - accessibility: Accessibility properties for EntryWidget MediaType Item.
        ///
        public init(
            chatTitle: String,
            audioTitle: String,
            videoTitle: String,
            secureMessagingTitle: String,
            callVisualizerTitle: String,
            titleFont: UIFont,
            titleColor: UIColor,
            titleTextStyle: UIFont.TextStyle,
            chatMessage: String,
            audioMessage: String,
            videoMessage: String,
            secureMessagingMessage: String,
            messageFont: UIFont,
            messageColor: UIColor,
            unreadMessagesCounterFont: UIFont,
            unreadMessagesCounterColor: UIColor,
            unreadMessagesCounterBackgroundColor: ColorType,
            messageTextStyle: UIFont.TextStyle,
            iconColor: ColorType,
            backgroundColor: ColorType,
            loading: LoadingStyle,
            accessibility: Accessibility,
            ongoingCoreEngagementMessage: String,
            ongoingCallVisualizerMessage: String,
            ongoingEngagementMessageFont: UIFont,
            ongoingEngagementMessageColor: UIColor
        ) {
            self.chatTitle = chatTitle
            self.audioTitle = audioTitle
            self.videoTitle = videoTitle
            self.secureMessagingTitle = secureMessagingTitle
            self.callVisualizerTitle = callVisualizerTitle
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.titleTextStyle = titleTextStyle
            self.chatMessage = chatMessage
            self.audioMessage = audioMessage
            self.videoMessage = videoMessage
            self.secureMessagingMessage = secureMessagingMessage
            self.messageFont = messageFont
            self.messageColor = messageColor
            self.unreadMessagesCounterFont = unreadMessagesCounterFont
            self.unreadMessagesCounterColor = unreadMessagesCounterColor
            self.unreadMessagesCounterBackgroundColor = unreadMessagesCounterBackgroundColor
            self.messageTextStyle = messageTextStyle
            self.iconColor = iconColor
            self.backgroundColor = backgroundColor
            self.loading = loading
            self.accessibility = accessibility
            self.ongoingCoreEngagementMessage = ongoingCoreEngagementMessage
            self.ongoingCallVisualizerMessage = ongoingCallVisualizerMessage
            self.ongoingEngagementMessageFont = ongoingEngagementMessageFont
            self.ongoingEngagementMessageColor = ongoingEngagementMessageColor
        }

        func title(for item: EntryWidget.MediaTypeItem) -> String {
            switch item.type {
            case .chat:
                return chatTitle
            case .audio:
                return audioTitle
            case .video:
                return videoTitle
            case .secureMessaging:
                return secureMessagingTitle
            case .callVisualizer:
                return callVisualizerTitle
            }
        }

        func message(for item: EntryWidget.MediaTypeItem) -> String {
            switch item.type {
            case .chat:
                return chatMessage
            case .audio:
                return audioMessage
            case .video:
                return videoMessage
            case .secureMessaging:
                return secureMessagingMessage
            case .callVisualizer:
                // This will not be used, because EntryWidget will show
                // ongoing engagement message there
                return ""
            }
        }
    }
}
