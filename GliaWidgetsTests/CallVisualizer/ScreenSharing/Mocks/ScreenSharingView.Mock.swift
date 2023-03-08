#if DEBUG

import UIKit

extension CallVisualizer.ScreenSharingView.Props {
    static func mock(
        style: ScreenSharingViewStyle = .mock(),
        header: Header.Props = .mock(),
        endScreenSharing: ActionButton.Props = .mock()
    ) -> CallVisualizer.ScreenSharingView.Props {
        return .init(style: style, header: header, endScreenSharing: endScreenSharing)
    }
}

#endif
