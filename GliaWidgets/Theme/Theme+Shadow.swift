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
        mutating func apply(configuration: RemoteConfiguration.Shadow?) {
            configuration?.color.map {
                $0.value
                    .first
                    .map { color = $0 }
            }

            configuration?.offset.map {
                offset = CGSize(width: $0, height: $0)
            }

            configuration?.opacity.map {
                opacity = Float($0)
            }

            configuration?.radius.map {
                radius = $0
            }
        }
    }
}
