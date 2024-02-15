import UIKit

extension OperatorTypingIndicatorStyle {
    func apply(configuration: RemoteConfiguration.Color?) {
        configuration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { color = $0 }
    }
}
