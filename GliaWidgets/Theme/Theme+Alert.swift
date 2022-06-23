extension Theme {
    var alertStyle: AlertStyle {
        typealias Alert = L10n.Alert
        typealias Accessibility = Alert.Accessibility

        let negativeAction = ActionButtonStyle(
            title: Alert.Action.no,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.systemNegative,
            accessibility: .init(
                label: Accessibility.Action.no,
                isFontScalingEnabled: true
            )
        )
        let positiveAction = ActionButtonStyle(
            title: Alert.Action.yes,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.primary,
            accessibility: .init(
                label: Accessibility.Action.yes,
                isFontScalingEnabled: true
            )
        )
        let poweredBy = PoweredByStyle(
            text: L10n.poweredBy,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )
        return AlertStyle(
            titleFont: font.header2,
            titleColor: color.baseDark,
            titleImageColor: color.primary,
            messageFont: font.bodyText,
            messageColor: color.baseDark,
            backgroundColor: color.background,
            closeButtonColor: color.baseNormal,
            actionAxis: .horizontal,
            positiveAction: positiveAction,
            negativeAction: negativeAction,
            poweredBy: poweredBy,
            accessibility: .init(isFontScalingEnabled: true)
        )
    }
}
