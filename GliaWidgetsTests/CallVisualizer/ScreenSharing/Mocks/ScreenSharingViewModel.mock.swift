#if DEBUG
import SwiftUI

extension CallVisualizer.ScreenSharingView.Model {
    static func mock(
        style: ScreenSharingViewStyle = .mock(),
        screenSharingHandler: ScreenShareHandler = .mock,
        log: CoreSdkClient.Logger = .mock
    ) -> CallVisualizer.ScreenSharingView.Model {
        .init(
            style: style,
            environment: .init(
                orientationManager: .mock(),
                uiApplication: .mock,
                screenShareHandler: screenSharingHandler,
                log: log
            )
        )
    }
}
#endif
