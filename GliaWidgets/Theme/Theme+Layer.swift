import Foundation
import UIKit

extension Theme {
    /// Abstract layer style.
    public struct Layer {
        /// Background hex color.
        public var background: String?
        /// Border hex color.
        public var borderColor: String
        /// Border width.
        public var borderWidth: CGFloat = 0
        /// Layer corner radius.
        public var cornerRadius: CGFloat = 0
        /// Initializes `Layer` style instance.
        public init(
            background: String? = nil,
            borderColor: String,
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
            switch configuration?.border?.type {
            case .fill:
                configuration?.border?.value
                    .first
                    .map { borderColor = $0 }
            case .gradient, .none:
                // The logic for gradient has not been implemented
                break
            }

            configuration?.borderWidth.map {
                borderWidth = $0
            }

            configuration?.cornerRadius.map {
                cornerRadius = $0
            }

            switch configuration?.color?.type {
            case .fill:
                background = configuration?.color?.value.first
            case .gradient, .none:
                // The logic for gradient has not been implemented
                break
            }
        }
    }
}
