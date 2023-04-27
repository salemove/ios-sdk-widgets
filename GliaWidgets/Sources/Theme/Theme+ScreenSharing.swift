import UIKit

extension Theme {
    var screenSharingStyle: ScreenSharingViewStyle {
        return ScreenSharingViewStyle(
            title: L10n.CallVisualizer.ScreenSharing.title,
            header: chat.header,
            messageText: L10n.CallVisualizer.ScreenSharing.message,
            messageTextFont: font.header2,
            messageTextColor: color.baseDark,
            buttonStyle: .init(
                title: L10n.CallVisualizer.ScreenSharing.Button.title,
                titleFont: font.buttonLabel,
                titleColor: color.baseLight,
                backgroundColor: .fill(color: color.systemNegative),
                cornerRaidus: 4,
                accessibility: .init(
                    label: L10n.CallVisualizer.ScreenSharing.Button.title,
                    isFontScalingEnabled: true
                )
            ),
            buttonIcon: Asset.startScreenShare.image,
            backgroundColor: .fill(color: color.baseLight),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
