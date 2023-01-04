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

extension SecureConversations.ConfirmationStyle {
    /// Style for title shown in the confirmation area.
    public struct TitleStyle: Equatable {
        /// Title text value.
        public var text: String
        /// Title font.
        public var font: UIFont
        /// Title color.
        public var color: UIColor

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
    }

    /// Style for subtitle shown in the confirmation area.
    public struct SubtitleStyle: Equatable {
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
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        public init(
            title: String,
            font: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor
        ) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
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
}
