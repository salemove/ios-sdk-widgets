#if DEBUG
import SwiftUI

extension CallVisualizer.ScreenSharingView.Model {
    static func mock(
        style: ScreenSharingViewStyle = .mock(),
        screenSharingHandler: ScreenShareHandler = .mock
    ) -> CallVisualizer.ScreenSharingView.Model {
        .init(
            style: style,
            environment: .init(
                orientationManager: .mock(),
                uiApplication: .mock,
                screenShareHandler: screenSharingHandler
            )
        )
    }
}
#endif
