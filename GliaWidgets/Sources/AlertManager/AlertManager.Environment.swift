import Foundation

extension AlertManager {
    struct Environment {
        let log: CoreSdkClient.Logger
        let uiApplication: UIKitBased.UIApplication
        let viewFactory: ViewFactory
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
