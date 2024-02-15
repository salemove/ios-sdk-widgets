import UIKit

public extension GvaGalleryCardStyle {
    struct TextStyle {
        /// Font of the card text label.
        public var font: UIFont

        /// Color of the card text label.
        public var textColor: UIColor

        /// Text style of the card text label.
        public var textStyle: UIFont.TextStyle

        /// - Parameters:
        ///   - font: Font of the card text label.
        ///   - textColor: Color of the card text label.
        ///   - textStyle: Text style of the card text label.
        ///
        public init(
            font: UIFont,
            textColor: UIColor,
            textStyle: UIFont.TextStyle
        ) {
            self.font = font
            self.textColor = textColor
            self.textStyle = textStyle
        }
    }
}

extension GvaGalleryCardStyle.TextStyle {
    static var initial: Self {
        .init(
            font: .systemFont(ofSize: 12),
            textColor: .black,
            textStyle: .body
        )
    }
}
