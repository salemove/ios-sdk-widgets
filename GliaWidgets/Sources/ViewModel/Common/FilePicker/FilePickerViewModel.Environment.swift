import Foundation

extension FilePickerViewModel {
    struct Environment {
        var log: CoreSdkClient.Logger
    }
}

extension FilePickerViewModel.Environment {
    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(log: environment.log)
    }

    static func create(with environment: ChatCoordinator.Environment) -> Self {
        .init(log: environment.log)
    }
}
