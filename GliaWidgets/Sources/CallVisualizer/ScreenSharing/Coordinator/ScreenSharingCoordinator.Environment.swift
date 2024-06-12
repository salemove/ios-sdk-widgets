import Foundation

extension CallVisualizer.ScreenSharingCoordinator {
    struct Environment {
        let theme: Theme
        let screenShareHandler: ScreenShareHandler
        let orientationManager: OrientationManager
        var log: CoreSdkClient.Logger
    }
}

extension CallVisualizer.ScreenSharingCoordinator.Environment {
    static func create(with environment: CallVisualizer.Coordinator.Environment) -> Self {
        .init(
            theme: environment.viewFactory.theme,
            screenShareHandler: environment.screenShareHandler,
            orientationManager: environment.orientationManager,
            log: environment.log
        )
    }
}
