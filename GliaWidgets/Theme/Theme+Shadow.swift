import Foundation
import UIKit

extension Theme {
    /// Shadow style.
    public struct Shadow {
        /// Shadow color.
        public var color: String
        /// Shadow offset.
        public var offset: CGSize
        /// Shadow opacity.
        public var opacity: Float
        /// Shadow radius.
        public var radius: CGFloat

        public static let standard: Shadow = .init(
            color: "0x000000",
            offset: .init(width: 0.0, height: 2.0),
            opacity: 0.3,
            radius: 2.0
        )

        /// Apply shadow configuration
        public mutating func applyShadowConfiguration(_ shadow: RemoteConfiguration.Shadow?) {
            shadow?.color?.type.map { shadowType in
                switch shadowType {
                case .fill:
                    shadow?.color?.value.map { shadowColors in
                        self.color = shadowColors[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented yet

                    break
                }
            }

            shadow?.offset.map { offset in
                self.offset = CGSize(width: offset, height: offset)
            }

            shadow?.opacity.map { opacity in
                self.opacity = Float(opacity)
            }

            shadow?.radius.map { radius in
                self.radius = radius
            }
        }
    }
}
