#if DEBUG

import UIKit

extension CallButtonBarStyle {
    static func mock(
        chatButton: CallButtonStyle = .mock(),
        videButton: CallButtonStyle = .mock(),
        muteButton: CallButtonStyle = .mock(),
        speakerButton: CallButtonStyle = .mock(),
        minimizeButton: CallButtonStyle = .mock(),
        badge: BadgeStyle = .mock()
    ) -> CallButtonBarStyle {
        return .init(
            chatButton: chatButton,
            videoButton: videButton,
            muteButton: muteButton,
            speakerButton: speakerButton,
            minimizeButton: minimizeButton,
            badge: badge
        )
    }
}

extension CallButtonStyle {
    static func mock(
        active: StateStyle = .activeMock(),
        inactive: StateStyle = .inactiveMock(),
        selected: StateStyle = .selectedMock(),
        accessibility: Accessibility = .unsupported
    ) -> CallButtonStyle {
        return .init(
            active: active,
            inactive: inactive,
            selected: selected,
            accessibility: accessibility
        )
    }
}

extension CallButtonStyle.StateStyle {
    static func activeMock(
        backgroundColor: ColorType = .fill(color: UIColor.white.withAlphaComponent(0.9)),
        image: UIImage = Asset.callChat.image,
        imageColor: ColorType = .fill(color: Color.baseDark),
        title: String = Localization.Media.Text.name,
        titleFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        titleColor: UIColor = Color.baseLight,
        textStyle: UIFont.TextStyle = .caption1,
        accessibility: Accessibility = .init(
            label: Localization.General.selected
        )
    ) -> CallButtonStyle.StateStyle {
        return .init(
            backgroundColor: backgroundColor,
            image: image,
            imageColor: imageColor,
            title: title,
            titleFont: titleFont,
            titleColor: titleColor,
            textStyle: textStyle,
            accessibility: accessibility
        )
    }

    static func inactiveMock(
        backgroundColor: ColorType = .fill(color: UIColor.black.withAlphaComponent(0.4)),
        image: UIImage = Asset.callChat.image,
        imageColor: ColorType = .fill(color: Color.baseLight),
        title: String = Localization.Media.Text.name,
        titleFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        titleColor: UIColor = Color.baseLight,
        textStyle: UIFont.TextStyle = .caption1,
        accessibility: Accessibility = .init(label: "")
    ) -> CallButtonStyle.StateStyle {
        return .init(
            backgroundColor: backgroundColor,
            image: image,
            imageColor: imageColor,
            title: title,
            titleFont: titleFont,
            titleColor: titleColor,
            textStyle: textStyle,
            accessibility: accessibility
        )
    }

    static func selectedMock(
        backgroundColor: ColorType = .fill(color: UIColor.black.withAlphaComponent(0.4)),
        image: UIImage = Asset.callChat.image,
        imageColor: ColorType = .fill(color: Color.baseLight),
        title: String = Localization.Media.Text.name,
        titleFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        titleColor: UIColor = Color.baseLight,
        textStyle: UIFont.TextStyle = .caption1,
        accessibility: Accessibility = .init(label: "")
    ) -> CallButtonStyle.StateStyle {
        return .init(
            backgroundColor: backgroundColor,
            image: image,
            imageColor: imageColor,
            title: title,
            titleFont: titleFont,
            titleColor: titleColor,
            textStyle: textStyle,
            accessibility: accessibility
        )
    }
}

#endif
