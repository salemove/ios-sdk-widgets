import Foundation
import UIKit

extension Theme {
    /// Shadow style
    public struct Shadow: Equatable {
        /// Shadow color
        public var color: String

        /// Shadow offset
        public var offset: CGSize

        /// Shadow opacity
        public var opacity: Float

        /// Shadow radius
        public var radius: CGFloat

        /// - Parameters:
        ///   - color: Shadow color
        ///   - offset: Shadow offset
        ///   - opacity: Shadow opacity
        ///   - radius: Shadow radius
        ///
        public init(
            color: String,
            offset: CGSize,
            opacity: Float,
            radius: CGFloat
        ) {
            self.color = color
            self.offset = offset
            self.opacity = opacity
            self.radius = radius
        }
    }
}

extension Theme.Shadow {
    public static let standard: Theme.Shadow = .init(
        color: "0x000000",
        offset: .init(width: 0.0, height: 2.0),
        opacity: 0.3,
        radius: 2.0
    )
}
