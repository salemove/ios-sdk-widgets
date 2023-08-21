#if DEBUG

import UIKit

extension HeaderStyle {
    static func mock(
        titleFont: UIFont = .systemFont(ofSize: 20, weight: .regular),
        titleColor: UIColor = .white,
        backgroundColor: ColorType = .fill(color: .blue),
        backButton: HeaderButtonStyle = .mock(),
        closeButton: HeaderButtonStyle = .mock(),
        endButton: ActionButtonStyle = .mock(),
        endScreenShareButton: HeaderButtonStyle = .mock()
    ) -> HeaderStyle {
        return .init(
            titleFont: titleFont,
            titleColor: titleColor,
            backgroundColor: backgroundColor,
            backButton: backButton,
            closeButton: closeButton,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton
        )
    }
}

extension HeaderButtonStyle {
    static func mock(
        image: UIImage = .mock,
        color: UIColor = .white
    ) -> HeaderButtonStyle {
        return .init(image: image, color: color)
    }
}

extension ActionButtonStyle {
    static func mock(
        title: String = Localization.ScreenSharing.VisitorScreen.end,
        titleFont: UIFont = .systemFont(ofSize: 16, weight: .regular),
        titleColor: UIColor = .white,
        backgroundColor: ColorType = .fill(color: Color.systemNegative)
    ) -> ActionButtonStyle {
        return .init(
            title: title,
            titleFont: titleFont,
            titleColor: titleColor,
            backgroundColor: backgroundColor
        )
    }
}

#endif
