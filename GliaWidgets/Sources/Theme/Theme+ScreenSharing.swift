import UIKit

extension Theme {
    var screenSharingStyle: ScreenSharingViewStyle {
        return ScreenSharingViewStyle(
            title: Localization.CallVisualizer.ScreenSharing.title,
            header: chat.header,
            messageText: Localization.CallVisualizer.ScreenSharing.message,
            messageTextFont: font.header2,
            messageTextColor: color.baseDark,
            buttonStyle: .init(
                title: Localization.ScreenSharing.VisitorScreen.end,
                titleFont: font.buttonLabel,
                titleColor: color.baseLight,
                backgroundColor: .fill(color: color.systemNegative),
                cornerRaidus: 4,
                accessibility: .init(
                    label: Localization.ScreenSharing.VisitorScreen.end,
                    isFontScalingEnabled: true
                )
            ),
            buttonIcon: Asset.startScreenShare.image,
            backgroundColor: .fill(color: color.baseLight),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
