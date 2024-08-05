import Foundation

#if DEBUG

extension AlertManager {
    static func mock(
        environment: AlertManager.Environment = .mock()
    ) -> AlertManager {
        return .init(environment: environment)
    }
}

extension AlertManager.Environment {
    static func mock(
        log: CoreSdkClient.Logger = .mock,
        uiApplication: UIKitBased.UIApplication = .mock,
        viewFactory: ViewFactory = .mock()
    ) -> AlertManager.Environment {
        return .init(
            log: log,
            uiApplication: uiApplication,
            viewFactory: viewFactory
        )
    }
}

#endif
