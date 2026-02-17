import UIKit

final class FilePickerController: NSObject {
    var viewController: UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: viewModel.allowedFiles.types, in: .import)
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
