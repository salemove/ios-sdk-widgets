import UIKit

extension Theme {
    var gliaVirtualAssistantStyle: GliaVirtualAssistantStyle {
        let font = ThemeFontStyle.default.font

        let persistentButton: GvaPersistentButtonStyle = .init(
            title: .init(
                textFont: font.bodyText,
                textColor: .black,
                backgroundColor: .clear
            ),
            backgroundColor: .fill(color: color.lightGrey),
            cornerRadius: 10,
            borderWidth: 0,
            borderColor: .clear,
            button: .init(
                textFont: font.caption,
                textColor: .black,
                backgroundColor: .fill(color: color.background),
                cornerRadius: 5,
                borderColor: .clear,
                borderWidth: 0
            )
        )

        let quickReplyButton: GvaQuickReplyButtonStyle = .init(
            textFont: font.buttonLabel,
            textColor: Color.primary,
            backgroundColor: .fill(color: Color.baseLight),
            cornerRadius: 10,
            borderColor: Color.primary,
            borderWidth: 1
        )

        return .init(
            persistentButton: persistentButton,
            quickReplyButton: quickReplyButton
        )
    }
}
