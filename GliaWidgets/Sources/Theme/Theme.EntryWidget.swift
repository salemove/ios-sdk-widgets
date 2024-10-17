import UIKit

extension Theme {
    var entryWidgetStyle: EntryWidgetStyle {
        let mediaTypeItem: EntryWidgetStyle.MediaTypeItemStyle = .init(
            titleFont: font.bodyText,
            titleColor: color.baseDark,
            titleTextStyle: .body,
            messageFont: font.caption,
            messageColor: color.baseNormal,
            messageTextStyle: .caption1,
            iconColor: .fill(color: color.primary),
            backgroundColor: .fill(color: color.baseLight)
        )

        let backgroundColor: ColorType = .fill(color: color.baseLight)

        let poweredBy = PoweredByStyle(
            text: Localization.General.powered,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let errorButton: ActionButtonStyle = .init(
            title: Localization.EntryWidget.ErrorState.TryAgain.label,
            titleFont: font.bodyText,
            titleColor: color.primary,
            backgroundColor: .fill(color: color.baseLight),
            shadowColor: .clear
        )

        let style: EntryWidgetStyle = .init(
            mediaTypeItem: mediaTypeItem,
            backgroundColor: backgroundColor,
            cornerRadius: 24,
            poweredBy: poweredBy,
            dividerColor: color.baseNeutral,
            errorTitleFont: font.header3,
            errorTitleStyle: .body,
            errorTitleColor: color.baseDark,
            errorMessageFont: font.bodyText,
            errorMessageStyle: .body,
            errorMessageColor: color.baseNormal,
            errorButton: errorButton
        )

        return style
    }
}
