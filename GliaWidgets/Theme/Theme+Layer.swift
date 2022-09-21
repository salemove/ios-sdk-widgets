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
        public mutating func applyLayerConfiguration(_ layer: RemoteConfiguration.Layer?) {
            layer?.border?.type.map { borderColorType in
                switch borderColorType {
                case .fill:
                    layer?.border?.value.map { borderColors in
                        self.borderColor = borderColors[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented

                    break
                }
            }

            layer?.borderWidth.map { borderWidth in
                self.borderWidth = borderWidth
            }

            layer?.cornerRadius.map { cornerRadius in
                self.cornerRadius = cornerRadius
            }

            layer?.color?.type.map { backgroundColorType in
                switch backgroundColorType {
                case .fill:
                    layer?.color?.value.map { backgroundColors in
                        self.background = backgroundColors[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented

                    break
                }
            }
        }
    }
}
