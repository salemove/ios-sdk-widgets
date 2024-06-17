import Foundation

extension FilePickerController {
    struct Environment {
        let fileManager: FoundationBased.FileManager
    }
}

extension FilePickerController.Environment {
    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(fileManager: environment.fileManager)
    }

    static func create(with environment: ChatCoordinator.Environment) -> Self {
        .init(fileManager: environment.fileManager)
    }
}
