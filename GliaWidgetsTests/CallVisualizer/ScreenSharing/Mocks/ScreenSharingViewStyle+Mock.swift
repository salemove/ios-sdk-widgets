#if DEBUG

import UIKit

extension ScreenSharingViewStyle {
    static func mock(
        title: String = ""
    ) -> ScreenSharingViewStyle {
        ScreenSharingViewStyle(
            title: title,
            header: .mock(),
            messageText: Localization.CallVisualizer.ScreenSharing.message,
            messageTextFont: .systemFont(ofSize: 20, weight: .regular),
            messageTextColor: Color.baseDark,
            buttonStyle: .mock(),
            buttonIcon: Asset.startScreenShare.image,
            backgroundColor: .fill(color: .white),
            accessibility: .unsupported
        )
    }
}

#endif
