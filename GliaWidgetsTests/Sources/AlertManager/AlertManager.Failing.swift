import Foundation
@testable import GliaWidgets

extension AlertManager {
    static func failing(
        environment: Environment = .failing(),
        viewFactory: ViewFactory
    ) -> AlertManager {
        .init(
            environment: environment,
            viewFactory: viewFactory
        )
    }
}

extension AlertManager.Environment {
    static func failing(
        log: CoreSdkClient.Logger = .failing,
        uiApplication: UIKitBased.UIApplication = .failing
    ) -> Self {
        .init(log: log, uiApplication: uiApplication)
    }
}
