import UIKit

extension Theme {
    var entryWidgetStyle: EntryWidgetStyle {
        let channel: EntryWidgetChannelStyle = .init(
            headlineFont: font.bodyText,
            headlineColor: color.baseDark,
            subheadlineFont: font.caption,
            subheadlineColor: color.baseNormal,
            iconColor: color.primary
        )

        let backgroundColor = color.baseLight

        let poweredBy = PoweredByStyle(
            text: Localization.General.powered,
            font: font.caption,
            accessibility: .init(isFontScalingEnabled: true)
        )

        let style: EntryWidgetStyle = .init(
            channel: channel,
            backgroundColor: backgroundColor,
            poweredBy: poweredBy,
            draggerColor: color.baseShade
        )

        return style
    }
}
