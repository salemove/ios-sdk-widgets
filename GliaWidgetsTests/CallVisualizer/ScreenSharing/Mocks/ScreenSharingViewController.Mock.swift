#if DEBUG

import UIKit

extension CallVisualizer.ScreenSharingViewController.Props {
    static func mock(
        screenShareViewProps: CallVisualizer.ScreenSharingView.Props = .mock()
    ) -> CallVisualizer.ScreenSharingViewController.Props {
        return .init(screenSharingViewProps: screenShareViewProps)
    }
}

#endif
