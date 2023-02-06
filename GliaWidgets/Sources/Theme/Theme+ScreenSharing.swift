import UIKit

extension Theme {
    var screenSharing: ScreenSharingViewStyle {
        return ScreenSharingViewStyle(
            title: L10n.ScreenSharing.title,
            header: chat.header,
            messageText: L10n.ScreenSharing.message,
            messageTextFont: font.header2,
            messageTextColor: color.baseDark,
            buttonStyle: .init(
                title: L10n.ScreenSharing.Button.title,
                titleFont: font.buttonLabel,
                titleColor: .white,
                backgroundColor: .fill(color: color.systemNegative),
                cornerRaidus: 4,
                accessibility: .init(
                    label: L10n.ScreenSharing.Button.title,
                    isFontScalingEnabled: true
                )
            ),
            buttonIcon: Asset.startScreenShare.image,
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
