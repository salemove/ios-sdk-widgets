import UIKit

extension UserImageStyle {
    mutating func apply(configuration: RemoteConfiguration.UserImageStyle?) {
        configuration?.placeholderColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { placeholderColor = $0 }

        configuration?.placeholderBackgroundColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { placeholderBackgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                placeholderBackgroundColor = .gradient(colors: colors)
            }
        }

        configuration?.imageBackgroundColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { imageBackgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageBackgroundColor = .gradient(colors: colors)
            }
        }
    }
}
