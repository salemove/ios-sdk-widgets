import UIKit

extension Theme.Text {
    /// Applies text from remote configuration.
    mutating func apply(
        configuration: RemoteConfiguration.Text?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.alignment.unwrap { alignment in
            switch alignment {
            case .center:
                self.alignment = .center
            case .leading:
                self.alignment = .left
            case .trailing:
                self.alignment = .right
            }
        }

        configuration?.background.unwrap { _ in
            // The logic for normal text background has not been implemented
        }

        UIFont.convertToFont(
            uiFont: assetsBuilder.fontBuilder(configuration?.font),
            textStyle: textStyle
        ).unwrap { font = $0 }

        configuration?.foreground?.value
            .first
            .unwrap { color = $0 }
    }
}
