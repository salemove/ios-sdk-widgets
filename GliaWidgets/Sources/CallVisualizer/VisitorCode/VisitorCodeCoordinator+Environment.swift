extension CallVisualizer.VisitorCodeCoordinator {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
    }
}

extension CallVisualizer.VisitorCodeCoordinator.Environment {
    static func create(with environment: CallVisualizer.Coordinator.Environment) -> Self {
        .init(
            timerProviding: environment.timerProviding,
            requestVisitorCode: environment.requestVisitorCode
        )
    }
}
