import Foundation

extension Glia.Authentication {
    struct Environment {
        var log: CoreSdkClient.Logger
    }
}

extension Glia.Authentication.Environment {
    static func create(with logger: CoreSdkClient.Logger) -> Self {
        .init(log: logger)
    }
}
