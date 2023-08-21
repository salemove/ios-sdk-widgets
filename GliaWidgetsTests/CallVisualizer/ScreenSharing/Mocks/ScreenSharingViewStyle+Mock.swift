#if DEBUG

import UIKit

extension ScreenSharingViewStyle {
    static func mock(
        title: String = "",
        messageTextFont: UIFont = .systemFont(ofSize: 20, weight: .medium),
        buttonTitleFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    ) -> ScreenSharingViewStyle {
        return ScreenSharingViewStyle(
            title: title,
            header: .mock(),
            messageText: Localization.CallVisualizer.ScreenSharing.message,
            messageTextFont: messageTextFont,
            messageTextColor: Color.baseDark,
            buttonStyle: .mock(titleFont: buttonTitleFont),
            buttonIcon: Asset.startScreenShare.image,
            backgroundColor: .fill(color: .white),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}

#endif
