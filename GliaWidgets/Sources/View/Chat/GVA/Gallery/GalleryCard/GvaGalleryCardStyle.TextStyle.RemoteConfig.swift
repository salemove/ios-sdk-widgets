import UIKit

extension GvaGalleryCardStyle.TextStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Text?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }
    }
}
