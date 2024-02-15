import UIKit

extension Theme.SnackBarStyle {
    mutating func apply(
        configuration: RemoteConfiguration.SnackBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.text?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap { textColor = $0 }

        configuration?.background?
            .value
            .first
            .map { .init(hex: $0) }
            .unwrap { background = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(.init(size: 17, style: .regular)),
            textStyle: .title3
        ).unwrap { textFont = $0 }
    }
}
