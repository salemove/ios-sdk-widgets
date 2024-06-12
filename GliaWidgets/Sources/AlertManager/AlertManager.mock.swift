import Foundation

#if DEBUG

extension AlertManager {
    static func mock(
        environment: AlertManager.Environment = .mock(),
        viewFactory: ViewFactory = .mock()
    ) -> AlertManager {
        return .init(environment: environment)
    }
}

extension AlertManager.Environment {
    static func mock(log: CoreSdkClient.Logger = .mock) -> AlertManager.Environment {
        return .init(
            log: log,
            uiApplication: .mock,
            viewFactory: .mock()
        )
    }
}

#endif
