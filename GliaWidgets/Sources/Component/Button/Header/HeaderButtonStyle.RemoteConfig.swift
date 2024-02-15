import UIKit

extension HeaderButtonStyle {
    mutating func apply(configuration: RemoteConfiguration.Button?) {
        configuration?.tintColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { color = $0 }
    }
}
