import Foundation

extension AlertManager.AlertTypeComposer {
    struct Environment {
        let log: CoreSdkClient.Logger
    }
}

extension AlertManager.AlertTypeComposer.Environment {
    static func create(with environment: AlertManager.Environment) -> Self {
        .init(log: environment.log)
    }
}
