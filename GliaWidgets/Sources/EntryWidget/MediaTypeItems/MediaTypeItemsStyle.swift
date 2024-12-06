import UIKit

extension EntryWidgetStyle {
    public struct MediaTypeItemsStyle: Equatable {
        /// The style of media type item.
        public var mediaItemStyle: EntryWidgetStyle.MediaTypeItemStyle

        /// The color of the divider.
        public var dividerColor: UIColor

        /// - Parameters:
        ///   - mediaItemStyle: Style of media type item..
        ///   - dividerColor: Color of the banner divider.
        public init(
            mediaItemStyle: EntryWidgetStyle.MediaTypeItemStyle,
            dividerColor: UIColor
        ) {
            self.mediaItemStyle = mediaItemStyle
            self.dividerColor = dividerColor
        }
    }
}
