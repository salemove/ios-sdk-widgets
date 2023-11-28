import UIKit

extension Theme {
    var webViewStyle: WebViewStyle {
        let closeButton = HeaderButtonStyle(
            image: Asset.close.image,
            color: color.baseLight,
            accessibility: .init(
                label: Localization.General.close,
                hint: ""
            )
        )
        let endButton = ActionButtonStyle(
            title: Localization.General.end,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.systemNegative),
            accessibility: .init(
                label: Localization.General.end,
                isFontScalingEnabled: true
            )
        )
        let endScreenShareButton = HeaderButtonStyle(
            image: Asset.startScreenShare.image,
            color: color.baseLight,
            accessibility: .init(
                label: Localization.ScreenSharing.VisitorScreen.End.title,
                hint: ""
            )
        )

        // endButton, endScreenShareButton and backButton
        // are hidden and not used on WebView screen
        let header = HeaderStyle(
            titleFont: font.header2,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.primary),
            backButton: nil,
            closeButton: closeButton,
            endButton: endButton,
            endScreenShareButton: endScreenShareButton,
            accessibility: .init(isFontScalingEnabled: true)
        )
        return .init(header: header)
    }
}
