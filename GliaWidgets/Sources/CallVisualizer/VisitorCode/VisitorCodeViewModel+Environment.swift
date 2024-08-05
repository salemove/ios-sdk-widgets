import Foundation

extension CallVisualizer.VisitorCodeViewModel {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
    }
}

extension CallVisualizer.VisitorCodeViewModel.Environment {
    static func create(with environment: CallVisualizer.VisitorCodeCoordinator.Environment) -> Self {
        .init(
            timerProviding: environment.timerProviding,
            requestVisitorCode: environment.requestVisitorCode
        )
    }
}
