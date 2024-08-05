extension Interactor {
    struct Environment {
        var coreSdk: CoreSdkClient
        var gcd: GCD
        var log: CoreSdkClient.Logger
    }
}

extension Interactor.Environment {
    static func create(
        with environment: Glia.Environment,
        log: CoreSdkClient.Logger
    ) -> Self {
        .init(
            coreSdk: environment.coreSdk,
            gcd: environment.gcd,
            log: log
        )
    }
}
