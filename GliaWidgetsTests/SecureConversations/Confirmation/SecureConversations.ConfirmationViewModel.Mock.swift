import UIKit
@testable import GliaWidgets

extension SecureConversations.ConfirmationStyle {
    static func mock(
        title: String = "",
        titleStyle: TitleStyle = .mock(),
        subtitleStyle: SubtitleStyle = .mock(),
        checkMessagesButtonStyle: CheckMessagesButtonStyle = .mock()
    ) -> SecureConversations.ConfirmationStyle {
        .init(
            header: .mock(),
            headerTitle: title,
            confirmationImage: .mock,
            confirmationImageTint: Color.baseLight,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            checkMessagesButtonStyle: checkMessagesButtonStyle,
            backgroundColor: Color.baseLight
        )
    }
}

extension SecureConversations.ConfirmationStyle.TitleStyle {
    static func mock(
        text: String = "Title label",
        font: UIFont = ThemeFont().header1,
        color: UIColor = Color.baseDark,
        accessibility: Accessibility = .unsupported
    ) -> SecureConversations.ConfirmationStyle.TitleStyle {
        return .init(
            text: text,
            font: font,
            color: color,
            accessibility: accessibility
        )
    }
}

extension SecureConversations.ConfirmationStyle.SubtitleStyle {
    static func mock(
        text: String = "Title label",
        font: UIFont = ThemeFont().header1,
        color: UIColor = Color.baseDark,
        accessibility: Accessibility = .unsupported
    ) -> SecureConversations.ConfirmationStyle.SubtitleStyle {
        return .init(
            text: text,
            font: font,
            color: color,
            accessibility: accessibility
        )
    }
}

extension SecureConversations.ConfirmationStyle.CheckMessagesButtonStyle {
    static func mock(
        title: String = "Title label",
        font: UIFont = ThemeFont().header1,
        textColor: UIColor = Color.baseDark,
        backgroundColor: UIColor = Color.baseLight,
        accessibility: Accessibility = .unsupported
    ) -> SecureConversations.ConfirmationStyle.CheckMessagesButtonStyle {
        return .init(
            title: title,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor,
            accessibility: accessibility
        )
    }
}

