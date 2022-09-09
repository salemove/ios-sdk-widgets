import Foundation
import UIKit

extension Theme {
    /// Abstract layer style.
    public struct Layer {
        /// Background hex color.
        public var background: ColorType?
        /// Border hex color.
        public var borderColor: CGColor
        /// Border width.
        public var borderWidth: CGFloat = 0
        /// Layer corner radius.
        public var cornerRadius: CGFloat = 0
        /// Initializes `Layer` style instance.
        public init(
            background: ColorType? = nil,
            borderColor: CGColor,
            borderWidth: CGFloat = 0,
            cornerRadius: CGFloat = 0
        ) {
            self.background = background
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }

        /// Apply layer remote configuration
        mutating func apply(configuration: RemoteConfiguration.Layer?) {
            configuration?.border?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { borderColor = $0.cgColor }

            configuration?.borderWidth.unwrap {
                borderWidth = $0
            }

            configuration?.cornerRadius.unwrap {
                cornerRadius = $0
            }

            configuration?.color.unwrap {
                switch $0.type {
                case .fill:
                    $0.value
                        .map { UIColor(hex: $0) }
                        .first
                        .unwrap { background = .fill(color: $0) }
                case .gradient:
                    let colors = $0.value.convertToCgColors()
                    background = .gradient(colors: colors)
                }
            }
        }
    }
}
