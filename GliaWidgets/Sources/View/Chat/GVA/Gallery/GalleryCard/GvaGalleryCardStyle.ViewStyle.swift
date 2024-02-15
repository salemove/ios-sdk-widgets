import UIKit

public extension GvaGalleryCardStyle {
    struct ViewStyle {
        /// Background color of the view.
        public var backgroundColor: ColorType

        /// Corner radius of the view.
        public var cornerRadius: CGFloat

        /// Color of the view's border.
        public var borderColor: UIColor

        /// Width of the view's border.
        public var borderWidth: CGFloat

        /// - Parameters:
        ///   - backgroundColor: Background color of the view.
        ///   - cornerRadius: Corner radius of the view.
        ///   - borderColor: Color of the view's border.
        ///   - borderWidth: Width of the view's border.
        ///
        public init(
            backgroundColor: ColorType,
            cornerRadius: CGFloat,
            borderColor: UIColor,
            borderWidth: CGFloat
        ) {
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }
    }
}

extension GvaGalleryCardStyle.ViewStyle {
    static var initial: Self {
        .init(
            backgroundColor: .fill(color: .clear),
            cornerRadius: 0,
            borderColor: .clear,
            borderWidth: 0
        )
    }
}
