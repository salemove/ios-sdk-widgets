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

        /// Style for description showm in the welcome area.
        public var welcomeSubtitleStyle: SubtitleStyle

        /// Style for button to check messages.
        public var checkMessagesButtonStyle: CheckMessagesButtonStyle

        /// Style for message text view title.
        public var messageTitleStyle: MessageTitleStyle

        /// Style for message text view.
        public var messageTextViewStyle: MessageTextViewStyle

        /// Style for send message button.
        public var sendButtonStyle: SendButtonStyle

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
        ///   - backgroundColor: Welcome area's view background color.
        public init(
            header: HeaderStyle,
            headerTitle: String,
            welcomeTitleStyle: TitleStyle,
            welcomeSubtitleStyle: SubtitleStyle,
            checkMessagesButtonStyle: CheckMessagesButtonStyle,
            messageTitleStyle: MessageTitleStyle,
            messageTextViewStyle: MessageTextViewStyle,
            sendButtonStyle: SendButtonStyle,
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
            self.backgroundColor = backgroundColor
        }
    }
}

extension SecureConversations.WelcomeStyle {
    /// Style for title shown in the welcome area.
    public struct TitleStyle: Equatable {
        /// Title text value.
        public var text: String
        /// Title font.
        public var font: UIFont
        /// Title color.
        public var color: UIColor

        /// - Parameters:
        ///   - text: Title text value.
        ///   - font: Title font.
        ///   - color: Title color.
        public init(
            text: String,
            font: UIFont,
            color: UIColor
        ) {
            self.text = text
            self.font = font
            self.color = color
        }

        /// Accessibility properties for TitleStyle.
        public struct Accessibility {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }
    }

    /// Style for description showm in the welcome area.
    public struct SubtitleStyle: Equatable {
        /// Subtitle text value.
        public var text: String
        /// Subtitle font.
        public var font: UIFont
        /// Subtitle color.
        public var color: UIColor

        /// - Parameters:
        ///   - text: Subtitle text value.
        ///   - font: Subtitle font.
        ///   - color: Subtitle color.
        public init(
            text: String,
            font: UIFont,
            color: UIColor
        ) {
            self.text = text
            self.font = font
            self.color = color
        }

        /// Accessibility properties for SubtitleStyle.
        public struct Accessibility {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }
    }

    /// Style for button to check messages.
    public struct CheckMessagesButtonStyle: Equatable {
        /// Button title.
        public var title: String
        /// Font of the button title.
        public var font: UIFont
        /// Color of the button title.
        public var color: UIColor

        /// - Parameters:
        ///   - title: Button title.
        ///   - font: Font of the button title.
        ///   - color: Color of the button title.
        public init(
            title: String,
            font: UIFont,
            color: UIColor
        ) {
            self.title = title
            self.font = font
            self.color = color
        }

        /// Accessibility properties for CheckMessagesButtonStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }
    }

    /// Style for message title.
    public struct MessageTitleStyle: Equatable {
        /// Message title text.
        public var title: String
        /// Font of the message title.
        public var font: UIFont
        /// Color of the message title.
        public var color: UIColor

        /// - Parameters:
        ///   - title: Message title text.
        ///   - font: Font of the message title.
        ///   - color: Color of the message title.
        public init(
            title: String,
            font: UIFont,
            color: UIColor
        ) {
            self.title = title
            self.font = font
            self.color = color
        }

        /// Accessibility properties for MessageTitleStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }
    }
    /// Style for message text view.
    public struct MessageTextViewStyle: Equatable {
        /// Placeholder text for text view.
        public var placeholderText: String
        /// Font for placeholder text.
        public var placeholderFont: UIFont
        /// Color for placeholder text.
        public var placeholderColor: UIColor
        /// Font for the text of text view.
        public var textFont: UIFont
        /// Color of the text.
        public var textColor: UIColor
        /// Color of the border of the text view.
        public var borderColor: UIColor
        /// Color of the border of the text view when it becomes first responder.
        public var activeBorderColor: UIColor
        /// Width of border for the text view.
        public var borderWidth: Double
        /// Border corner radius.
        public var cornerRadius: Double

        /// - Parameters:
        ///   - placeholderText: Placeholder text for text view.
        ///   - placeholderFont: Font for placeholder text.
        ///   - placeholderColor: Color for placeholder text.
        ///   - textFont: Font for the text of text view.
        ///   - textColor: Color of the text.
        ///   - borderColor: Color of the border of the text view.
        ///   - activeBorderColor: Color of the border of the text view when it becomes first responder.
        ///   - borderWidth: Width of border for the text view.
        ///   - cornerRadius: Border corner radius.
        public init(
            placeholderText: String,
            placeholderFont: UIFont,
            placeholderColor: UIColor,
            textFont: UIFont,
            textColor: UIColor,
            borderColor: UIColor,
            activeBorderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double
        ) {
            self.placeholderText = placeholderText
            self.placeholderFont = placeholderFont
            self.placeholderColor = placeholderColor
            self.textFont = textFont
            self.textColor = textColor
            self.borderColor = borderColor
            self.activeBorderColor = activeBorderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }

        /// Accessibility properties for MessageTextViewStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }
    }

    /// Style for send message button.
    public struct SendButtonStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor

        /// Accessibility properties for SendButtonStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool

            /// - Parameter isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public init(isFontScalingEnabled: Bool) {
                self.isFontScalingEnabled = isFontScalingEnabled
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(isFontScalingEnabled: false)
        }
    }
}
