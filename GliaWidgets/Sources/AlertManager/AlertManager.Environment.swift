import Foundation

extension AlertManager {
    struct Environment {
        var log: CoreSdkClient.Logger
        var uiApplication: UIKitBased.UIApplication
        var viewFactory: ViewFactory
    }
}

extension AlertManager.Environment {
    static func create(
        with environment: Glia.Environment,
        logger: CoreSdkClient.Logger,
        viewFactory: ViewFactory
    ) -> Self {
        .init(
            log: logger,
            uiApplication: environment.uiApplication,
            viewFactory: viewFactory
        )
    }
}
