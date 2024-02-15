import UIKit

extension GvaGalleryCardStyle.ViewStyle {
    mutating func apply(configuration: RemoteConfiguration.Layer?) {
        configuration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.color.unwrap {
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
