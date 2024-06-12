import Foundation

extension FilePickerController {
    public struct Environment {
        let fileManager: FoundationBased.FileManager
    }
}

extension FilePickerController.Environment {
    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(fileManager: environment.fileManager)
    }
}
