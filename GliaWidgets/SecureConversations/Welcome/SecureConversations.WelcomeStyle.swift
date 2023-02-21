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

extension SecureConversations.WelcomeStyle {
    /// Style for title shown in the welcome area.
    public struct TitleStyle: Equatable {
        /// Title text value.
        public var text: String
        /// Title font.
        public var font: UIFont
        /// Title color.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Title text value.
        ///   - font: Title font.
        ///   - color: Title color.
        ///   - accessibility: Accessibility related properties.
        public init(
            text: String,
            font: UIFont,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.text = text
            self.font = font
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for TitleStyle.
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

    /// Style for description showm in the welcome area.
    public struct SubtitleStyle: Equatable {
        /// Subtitle text value.
        public var text: String
        /// Subtitle font.
        public var font: UIFont
        /// Subtitle color.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Subtitle text value.
        ///   - font: Subtitle font.
        ///   - color: Subtitle color.
        ///   - accessibility: Accessibility related properties.
        public init(
            text: String,
            font: UIFont,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.text = text
            self.font = font
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for SubtitleStyle.
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

    /// Style for button to check messages.
    public struct CheckMessagesButtonStyle: Equatable {
        /// Button title.
        public var title: String
        /// Font of the button title.
        public var font: UIFont
        /// Color of the button title.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Button title.
        ///   - font: Font of the button title.
        ///   - color: Color of the button title.
        public init(
            title: String,
            font: UIFont,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for CheckMessagesButtonStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
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
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Message title text.
        ///   - font: Font of the message title.
        ///   - color: Color of the message title.
        public init(
            title: String,
            font: UIFont,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.color = color
            self.accessibility = accessibility
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
        /// Style of normal state for message text view.
        public var normalStyle: MessageTextViewNormalStyle
        /// Style of disabled state for message text view.
        public var disabledStyle: MessageTextViewDisabledStyle
        /// Style of active state for message text view.
        public var activeStyle: MessageTextViewActiveStyle

        /// - Parameters:
        ///   - normalStyle: Style of normal state for message text view.
        ///   - disabledStyle: Style of disabled state for message text view.
        ///   - activeStyle: Style of active state for message text view.
        public init(
            normalStyle: SecureConversations.WelcomeStyle.MessageTextViewNormalStyle,
            disabledStyle: SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle,
            activeStyle: SecureConversations.WelcomeStyle.MessageTextViewActiveStyle) {
            self.normalStyle = normalStyle
            self.disabledStyle = disabledStyle
            self.activeStyle = activeStyle
        }
    }

    /// Style of disabled state for message text view.
    public struct MessageTextViewDisabledStyle: Equatable {
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
        /// Width of border for the text view.
        public var borderWidth: Double
        /// Border corner radius.
        public var cornerRadius: Double
        /// Color of the background of the text view.
        public var backgroundColor: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - placeholderText: Placeholder text for text view.
        ///   - placeholderFont: Font for placeholder text.
        ///   - placeholderColor: Color for placeholder text.
        ///   - textFont: Font for the text of text view.
        ///   - textColor: Color of the text.
        ///   - borderColor: Color of the border of the text view.
        ///   - borderWidth: Width of border for the text view.
        ///   - cornerRadius: Border corner radius.
        ///   - backgroundColor: Color of the background of the text view.
        public init(
            placeholderText: String,
            placeholderFont: UIFont,
            placeholderColor: UIColor,
            textFont: UIFont,
            textColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            backgroundColor: UIColor,
            accessibility: Accessibility
        ) {
            self.placeholderText = placeholderText
            self.placeholderFont = placeholderFont
            self.placeholderColor = placeholderColor
            self.textFont = textFont
            self.textColor = textColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for MessageTextViewDisabledStyle.
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

    /// Style of normal state for message text view.
    public struct MessageTextViewNormalStyle: Equatable {
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
        /// Width of border for the text view.
        public var borderWidth: Double
        /// Border corner radius.
        public var cornerRadius: Double
        /// Color of the background of the text view.
        public var backgroundColor: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - placeholderText: Placeholder text for text view.
        ///   - placeholderFont: Font for placeholder text.
        ///   - placeholderColor: Color for placeholder text.
        ///   - textFont: Font for the text of text view.
        ///   - textColor: Color of the text.
        ///   - borderColor: Color of the border of the text view.
        ///   - borderWidth: Width of border for the text view.
        ///   - cornerRadius: Border corner radius.
        ///   - backgroundColor: Color of the background of the text view.
        public init(
            placeholderText: String,
            placeholderFont: UIFont,
            placeholderColor: UIColor,
            textFont: UIFont,
            textColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            backgroundColor: UIColor,
            accessibility: Accessibility
        ) {
            self.placeholderText = placeholderText
            self.placeholderFont = placeholderFont
            self.placeholderColor = placeholderColor
            self.textFont = textFont
            self.textColor = textColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for MessageTextViewNormalStyle.
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

    /// Style of active state for message text view.
    public struct MessageTextViewActiveStyle: Equatable {
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
        /// Width of border for the text view.
        public var borderWidth: Double
        /// Border corner radius.
        public var cornerRadius: Double
        /// Color of the background of the text view.
        public var backgroundColor: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - placeholderText: Placeholder text for text view.
        ///   - placeholderFont: Font for placeholder text.
        ///   - placeholderColor: Color for placeholder text.
        ///   - textFont: Font for the text of text view.
        ///   - textColor: Color of the text.
        ///   - borderColor: Color of the border of the text view.
        ///   - borderWidth: Width of border for the text view.
        ///   - cornerRadius: Border corner radius.
        ///   - backgroundColor: Color of the background of the text view.
        public init(
            placeholderText: String,
            placeholderFont: UIFont,
            placeholderColor: UIColor,
            textFont: UIFont,
            textColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            backgroundColor: UIColor,
            accessibility: Accessibility
        ) {
            self.placeholderText = placeholderText
            self.placeholderFont = placeholderFont
            self.placeholderColor = placeholderColor
            self.textFont = textFont
            self.textColor = textColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for MessageTextViewActiveStyle.
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
        /// Style for enabled state of send message button.
        public var enabledStyle: SendButtonEnabledStyle
        /// Style for disabled state of send message button.
        public var disabledStyle: SendButtonDisabledStyle
        /// Style for loading state of send message button.
        public var loadingStyle: SendButtonLoadingStyle

        /// - Parameters:
        ///   - enabledStyle: Style for enabled state of send message button.
        ///   - disabledStyle: Style for disabled state of send message button.
        ///   - loadingStyle: Style for loading state of send message button.
        public init(
            enabledStyle: SecureConversations.WelcomeStyle.SendButtonEnabledStyle,
            disabledStyle: SecureConversations.WelcomeStyle.SendButtonDisabledStyle,
            loadingStyle: SendButtonLoadingStyle
        ) {
            self.enabledStyle = enabledStyle
            self.disabledStyle = disabledStyle
            self.loadingStyle = loadingStyle
        }
    }

    /// Style for enabled state of send message button.
    public struct SendButtonEnabledStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Border color of the button.
        public var borderColor: UIColor
        /// Border width of the button.
        public var borderWidth: Double
        /// Corner radius of the button.
        public var cornerRadius: Double
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - cornerRadius: Corner radius of the button.
        public init(
            title: String,
            font: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.accessibility = accessibility
        }

        /// Accessibility properties for SendButtonEnabledStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
        }
    }

    /// Style for disabled state of send message button.
    public struct SendButtonDisabledStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Border color of the button.
        public var borderColor: UIColor
        /// Border width of the button.
        public var borderWidth: Double
        /// Corner radius of the button.
        public var cornerRadius: Double
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - cornerRadius: Corner radius of the button.
        public init(
            title: String,
            font: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.accessibility = accessibility
        }

        /// Accessibility properties for SendButtonDisabledStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
        }
    }

    /// Style for loading state of send message button.
    public struct SendButtonLoadingStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Border color of the button.
        public var borderColor: UIColor
        /// Border width of the button.
        public var borderWidth: Double
        /// Color of the activity indicator of the button.
        public var activityIndicatorColor: UIColor
        /// Corner radius of the button.
        public var cornerRadius: Double
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - activityIndicatorColor: Color of the activity indicator of the button.
        ///   - cornerRadius: Corner radius of the button.
        public init(
            title: String,
            font: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            activityIndicatorColor: UIColor,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.activityIndicatorColor = activityIndicatorColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for SendButtonEnabledStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
        }
    }

    /// Style for message warning section.
    public struct MessageWarningStyle: Equatable {
        /// Color of the warning text.
        public var textColor: UIColor
        /// Font of the warning text.
        public var textFont: UIFont
        /// Color of the warning icon image.
        public var iconColor: UIColor
        /// Text for the message limit warning.
        public var messageLengthLimitText: String
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - textColor: Color of the warning text.
        ///   - textFont: Font of the warning text.
        ///   - iconColor: Color of the warning icon image.
        ///   - messageLengthLimitText: Text for the message limit warning.
        public init(
            textColor: UIColor,
            textFont: UIFont,
            iconColor: UIColor,
            messageLengthLimitText: String,
            accessibility: Accessibility
        ) {
            self.textColor = textColor
            self.textFont = textFont
            self.iconColor = iconColor
            self.messageLengthLimitText = messageLengthLimitText
            self.accessibility = accessibility
        }

        /// Accessibility properties for MessageWarningStyle.
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

    ///  Style for file picker button.
    public struct FilePickerButtonStyle: Equatable {
        /// Button image color.
        public var color: UIColor
        /// Button image color for disabled state.
        public var disabledColor: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - color: Button image color.
        ///   - disabledColor: Button image color for disabled state.
        public init(
            color: UIColor,
            disabledColor: UIColor,
            accessibility: Accessibility
        ) {
            self.color = color
            self.disabledColor = disabledColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for FilePickerButtonStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                accessibilityLabel: String,
                accessibilityHint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = accessibilityLabel
                self.hint = accessibilityHint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                accessibilityLabel: "",
                accessibilityHint: ""
            )
        }
    }

    /// Style for title icon image.
    public struct TitleImageStyle: Equatable {
        /// Color of the image.
        public var color: UIColor
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameter color: Color of the image.
        public init(
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.color = color
            self.accessibility = accessibility
        }

        /// Accessibility properties for TitleImageStyle.
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
