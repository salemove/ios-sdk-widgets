extension Interactor {
    struct Environment {
        var coreSdk: CoreSdkClient
        var queuesMonitor: QueuesMonitor
        var gcd: GCD
        var log: CoreSdkClient.Logger
        var alertManager: AlertManager
    }
}

extension Interactor.Environment {
    static func create(
        with environment: Glia.Environment,
        log: CoreSdkClient.Logger,
        queuesMonitor: QueuesMonitor,
        alertManager: AlertManager
    ) -> Self {
        .init(
            coreSdk: environment.coreSdk,
            queuesMonitor: queuesMonitor,
            gcd: environment.gcd,
            log: log,
            alertManager: alertManager
        )
    }
}
