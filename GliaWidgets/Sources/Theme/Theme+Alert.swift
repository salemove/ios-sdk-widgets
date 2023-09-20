extension Theme {
    var alertStyle: AlertStyle {
        let negativeAction = ActionButtonStyle(
            title: Localization.General.no,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.systemNegative),
            accessibility: .init(
                label: Localization.General.no,
                isFontScalingEnabled: true
            )
        )
        let positiveAction = ActionButtonStyle(
            title: Localization.General.yes,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: .fill(color: color.primary),
            accessibility: .init(
                label: Localization.General.yes,
                isFontScalingEnabled: true
            )
        )
        let poweredBy = PoweredByStyle(
            text: Localization.General.powered,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )
        return AlertStyle(
            titleFont: font.header2,
            titleColor: color.baseDark,
            titleImageColor: color.primary,
            messageFont: font.bodyText,
            messageColor: color.baseDark,
            backgroundColor: .fill(color: color.baseLight),
            closeButtonColor: .fill(color: color.baseNormal),
            actionAxis: .horizontal,
            positiveAction: positiveAction,
            negativeAction: negativeAction,
            poweredBy: poweredBy,
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
