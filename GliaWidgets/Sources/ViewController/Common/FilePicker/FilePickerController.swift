import UIKit
import UniformTypeIdentifiers

final class FilePickerController: NSObject {
    var viewController: UIDocumentPickerViewController {
        let contentTypes = viewModel.allowedFiles.types.compactMap { UTType($0) }
        let safeTypes = contentTypes.isEmpty ? [.data] : contentTypes
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: safeTypes,
            asCopy: true
        )

        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen

        let urls = environment.fileManager.urlsForDirectoryInDomainMask(.documentDirectory, .userDomainMask)
        documentPicker.directoryURL = urls.first

        return documentPicker
    }

    private let viewModel: FilePickerViewModel
    private let environment: Environment

    init(
        viewModel: FilePickerViewModel,
        environment: Environment
    ) {
        self.viewModel = viewModel
        self.environment = environment
    }
}

extension FilePickerController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        viewModel.event(.pickedFile(url))
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
        viewModel.event(.cancelled)
    }
}
