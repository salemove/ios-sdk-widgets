import UIKit

extension OnHoldOverlayStyle {
    mutating func apply(configuration: RemoteConfiguration.OnHoldOverlayStyle?) {
        configuration?.tintColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { imageColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageColor = .gradient(colors: colors)
            }
        }

        configuration?.backgroundColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }
    }
}
