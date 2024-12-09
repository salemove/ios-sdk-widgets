import Foundation

extension GliaPresenter {
    struct Environment {
        var appWindowsProvider: AppWindowsProvider
        var log: CoreSdkClient.Logger
        var dismissManager: DismissManager
    }
}

extension GliaPresenter.Environment {
    static func create(
        with environment: EngagementCoordinator.Environment,
        sceneProvider: SceneProvider?
    ) -> Self {
        .init(
            appWindowsProvider: .init(
                uiApplication: environment.uiApplication,
                sceneProvider: sceneProvider
            ),
            log: environment.log,
            dismissManager: environment.dismissManager
        )
    }

    static func create(
        with environment: Glia.Environment,
        log: CoreSdkClient.Logger,
        sceneProvider: SceneProvider?
    ) -> Self {
            .init(
                appWindowsProvider: .init(
                    uiApplication: environment.uiApplication,
                    sceneProvider: sceneProvider
                ),
                log: log,
                dismissManager: environment.dismissManager
            )
    }
}
