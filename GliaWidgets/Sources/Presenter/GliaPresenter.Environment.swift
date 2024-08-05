import Foundation

extension GliaPresenter {
    struct Environment {
        var appWindowsProvider: AppWindowsProvider
        var log: CoreSdkClient.Logger
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
            log: environment.log
        )
    }
}
