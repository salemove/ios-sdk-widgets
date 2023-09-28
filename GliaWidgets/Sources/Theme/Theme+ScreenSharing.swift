import UIKit

extension Theme {
    var screenSharingStyle: ScreenSharingViewStyle {
        return ScreenSharingViewStyle(
            title: Localization.CallVisualizer.ScreenSharing.Header.title,
            header: chat.header,
            messageText: Localization.CallVisualizer.ScreenSharing.message,
            messageTextFont: font.header2,
            messageTextColor: color.baseDark,
            buttonStyle: .init(
                title: Localization.ScreenSharing.VisitorScreen.End.title,
                titleFont: font.buttonLabel,
                titleColor: color.baseLight,
                backgroundColor: .fill(color: color.systemNegative),
                cornerRaidus: 4,
                accessibility: .init(
                    label: Localization.ScreenSharing.VisitorScreen.End.title,
                    isFontScalingEnabled: true
                )
            ),
            buttonIcon: Asset.startScreenShare.image,
            backgroundColor: .fill(color: color.baseLight),
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
