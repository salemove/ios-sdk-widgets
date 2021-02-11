extension Theme {
    var alertStyle: AlertStyle {
        typealias Alert = L10n.Alert

        let negativeAction = ActionButtonStyle(
            title: Alert.Action.no,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.systemNegative
        )
        let positiveAction = ActionButtonStyle(
            title: Alert.Action.yes,
            titleFont: font.buttonLabel,
            titleColor: color.baseLight,
            backgroundColor: color.primary
        )
        return AlertStyle(
            titleFont: font.header2,
            titleColor: color.baseDark,
            titleImageColor: color.primary,
            messageFont: font.bodyText,
            messageColor: color.baseDark,
            backgroundColor: color.background,
            closeButtonColor: color.baseNormal,
            positiveAction: positiveAction,
            negativeAction: negativeAction
        )
    }
}
