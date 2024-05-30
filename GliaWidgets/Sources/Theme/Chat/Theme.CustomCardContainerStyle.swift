import UIKit

public extension Theme {
    /// Style of a Custom Card container.
    struct CustomCardContainerStyle {
        /// Style of the operator's image.
        public var operatorImage: UserImageStyle

        ///
        /// - Parameter operatorImage: Style of the operator's image.
        public init(operatorImage: UserImageStyle) {
            self.operatorImage = operatorImage
        }
    }
}
