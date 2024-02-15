import UIKit

extension Theme.Shadow {
    /// Applies shadow configuration.
    mutating func apply(configuration: RemoteConfiguration.Shadow?) {
        configuration?.color?.value
            .first
            .unwrap { color = $0 }

        configuration?.offset.unwrap {
            offset = CGSize(width: $0, height: $0)
        }

        configuration?.opacity.unwrap {
            opacity = Float($0)
        }

        configuration?.radius.unwrap {
            radius = $0
        }
    }
}
