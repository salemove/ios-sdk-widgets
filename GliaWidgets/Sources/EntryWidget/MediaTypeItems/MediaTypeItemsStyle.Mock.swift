#if DEBUG
import UIKit

extension EntryWidgetStyle.MediaTypeItemsStyle {
    static func mock(
        mediaItemStyle: EntryWidgetStyle.MediaTypeItemStyle = .mock(),
        dividerColor: UIColor = .gray
    ) -> Self {
        Self(
            mediaItemStyle: mediaItemStyle,
            dividerColor: dividerColor
        )
    }
}
#endif
