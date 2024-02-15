import Foundation

public extension GvaGalleryCardStyle {
    struct ButtonStyle {
        /// Style of the button title.
        public var title: TextStyle

        /// Style of the button background.
        public var background: ViewStyle

        /// - Parameters:
        ///   - title: Style of the button title.
        ///   - background: Style of the button background.
        ///
        public init(
            title: TextStyle,
            background: ViewStyle
        ) {
            self.title = title
            self.background = background
        }
    }
}

extension GvaGalleryCardStyle.ButtonStyle {
    static var initial: Self {
        .init(
            title: .initial,
            background: .initial
        )
    }
}
