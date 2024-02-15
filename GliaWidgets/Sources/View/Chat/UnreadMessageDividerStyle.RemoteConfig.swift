import UIKit

extension UnreadMessageDividerStyle {
    func apply(
        lineColor: RemoteConfiguration.Color?,
        text: RemoteConfiguration.Text?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        lineColor?.value.map { UIColor(hex: $0) }
            .first
            .unwrap { self.lineColor = $0 }

        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(text?.font),
            textStyle: .body
        ).unwrap { titleFont = $0 }

        text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { titleColor = $0 }
    }
}
