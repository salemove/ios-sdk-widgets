import Foundation
@_spi(GliaWidgets) import GliaCoreSDK
import UIKit
import UniformTypeIdentifiers

extension FilePickerController {
    struct Environment {
        let fileManager: FoundationBased.FileManager
        @Dependency(\.widgets.documentPicker) var documentPicker: DocumentPicker
    }

    /// Creates the system document picker. `UIDocumentPickerViewController` connects to the
    /// out-of-process DocumentManager service as soon as it is created, so unit tests inject
    /// a plain view controller instead.
    struct DocumentPicker {
        var make: (
            _ contentTypes: [UTType],
            _ directoryURL: URL?,
            _ delegate: UIDocumentPickerDelegate
        ) -> UIViewController
    }
}

extension FilePickerController.DocumentPicker {
    static let live = Self { contentTypes, directoryURL, delegate in
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: contentTypes,
            asCopy: true
        )
        documentPicker.delegate = delegate
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        documentPicker.directoryURL = directoryURL
        return documentPicker
    }

    struct Key: DependencyKey {
        static var live: FilePickerController.DocumentPicker = .live
        static var test: FilePickerController.DocumentPicker = .init { _, _, _ in UIViewController() }
    }
}

extension DependencyContainer.Widgets {
    var documentPicker: FilePickerController.DocumentPicker {
        get { self[FilePickerController.DocumentPicker.Key.self] }
        set { self[FilePickerController.DocumentPicker.Key.self] = newValue }
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
