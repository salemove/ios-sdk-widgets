import Foundation

extension CallVisualizer.ScreenSharingCoordinator {
    struct Environment {
        let theme: Theme
        let screenShareHandler: ScreenShareHandler
        let orientationManager: OrientationManager
        var log: CoreSdkClient.Logger
    }
}
