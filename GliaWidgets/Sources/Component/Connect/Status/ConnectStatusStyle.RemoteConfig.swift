import UIKit

extension ConnectStatusStyle {
    mutating func apply(
        configuration: RemoteConfiguration.EngagementState?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.title?.font),
            textStyle: firstTextStyle
        ).unwrap { firstTextFont = $0 }

        configuration?.title?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { firstTextFontColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.description?.font),
            textStyle: secondTextStyle
        ).unwrap { secondTextFont = $0 }

        configuration?.description?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { secondTextFontColor = $0 }
    }
}
