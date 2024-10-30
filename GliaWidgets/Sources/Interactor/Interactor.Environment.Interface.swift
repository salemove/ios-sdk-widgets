extension Interactor {
    struct Environment {
        var coreSdk: CoreSdkClient
        var queuesMonitor: QueuesMonitor
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
            queuesMonitor: environment.queuesMonitor,
            gcd: environment.gcd,
            log: log
        )
    }
}
