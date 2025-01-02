import Foundation

extension QuickLookViewModel {
    struct Environment {
        var log: CoreSdkClient.Logger
    }
}

extension QuickLookViewModel.Environment {
    static func create(with environment: ChatCoordinator.Environment) -> Self {
        .init(log: environment.log)
    }
}
