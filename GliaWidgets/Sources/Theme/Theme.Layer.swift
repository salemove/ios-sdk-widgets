import Foundation
import UIKit

extension Theme {
    /// Abstract layer style
    public struct Layer {
        /// Background hex color
        public var background: ColorType?

        /// Border hex color
        public var borderColor: CGColor

        /// Border width
        public var borderWidth: CGFloat = 0

        /// Layer corner radius
        public var cornerRadius: CGFloat = 0

        /// - Parameters:
        ///   - background: Background hex color
        ///   - borderColor: Border hex color
        ///   - borderWidth: Border width
        ///   - cornerRadius: Layer corner radius
        ///
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
    }
}
