import UIKit

extension ChoiceCardOptionStateStyle {
    func apply(
        configuration: RemoteConfiguration.Button?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.background?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { textColor = $0 }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.text?.font),
            textStyle: textStyle
        ).unwrap { textFont = $0 }
    }
}
