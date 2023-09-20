import UIKit

extension Theme {
    var visitorCodeStyle: VisitorCodeStyle {
        let numberSlot = NumberSlotStyle(
            backgroundColor: .fill(color: color.baseLight),
            borderColor: color.baseNeutral,
            borderWidth: 1,
            cornerRadius: 8,
            numberFont: font.header1,
            numberColor: color.baseDark,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let actionButton = ActionButtonStyle(
            title: Localization.General.refresh,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.primary)
        )

        let poweredBy = PoweredByStyle(
            text: Localization.General.powered,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )

        return VisitorCodeStyle(
            titleFont: font.header2,
            titleColor: color.baseDark,
            poweredBy: poweredBy,
            numberSlot: numberSlot,
            actionButton: actionButton,
            backgroundColor: .fill(color: color.baseLight),
            cornerRadius: 30,
            closeButtonColor: .fill(color: color.baseNormal),
            loadingProgressColor: color.primary,
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
