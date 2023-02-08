import UIKit

extension Theme {
    var visitorCodeStyle: VisitorCodeStyle {
        let numberSlot = NumberSlotStyle(
            backgroundColor: .fill(color: color.background),
            borderColor: UIColor.ultraLightGray,
            borderWidth: 1,
            cornerRadius: 8,
            numberFont: font.header1,
            numberColor: color.baseDark,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let actionButton = ActionButtonStyle(
            title: L10n.VisitorCode.Action.refresh,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.primary)
        )

        let poweredBy = PoweredByStyle(
            text: L10n.poweredBy,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )

        return VisitorCodeStyle(
            titleFont: font.header2,
            titleColor: color.baseDark,
            poweredBy: poweredBy,
            numberSlot: numberSlot,
            actionButton: actionButton,
            backgroundColor: .fill(color: color.background),
            cornerRadius: 30,
            closeButtonColor: .fill(color: color.baseNormal),
            loadingProgressColor: color.primary,
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}

private extension UIColor {
    static let ultraLightGray = UIColor(red: 0.953, green: 0.953, blue: 0.953, alpha: 1)
}
