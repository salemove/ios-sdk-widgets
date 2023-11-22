extension Theme {
    var alertStyle: AlertStyle {
        let firstLinkAction = ActionButtonStyle(
            title: Localization.Engagement.Confirm.Link1.text,
            titleFont: font.buttonLabel,
            titleColor: color.primary,
            backgroundColor: .fill(color: .clear),
            accessibility: .init(
                label: Localization.Engagement.Confirm.Link1.Accessibility.label,
                isFontScalingEnabled: true
            )
        )
        let secondLinkAction = ActionButtonStyle(
            title: Localization.Engagement.Confirm.Link2.text,
            titleFont: font.buttonLabel,
            titleColor: color.primary,
            backgroundColor: .fill(color: .clear),
            accessibility: .init(
                label: Localization.Engagement.Confirm.Link2.Accessibility.label,
                isFontScalingEnabled: true
            )
        )
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
            firstLinkAction: firstLinkAction,
            secondLinkAction: secondLinkAction,
            actionAxis: .horizontal,
            positiveAction: positiveAction,
            negativeAction: negativeAction,
            poweredBy: poweredBy,
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
