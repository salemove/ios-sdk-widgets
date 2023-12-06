extension Interactor {
    struct Environment {
        var coreSdk: CoreSdkClient
        var gcd: GCD
        var log: CoreSdkClient.Logger
    }
}
