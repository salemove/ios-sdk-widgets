import UIKit

final class FilePickerController: NSObject {
    var viewController: UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: viewModel.allowedFiles.types, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        return documentPicker
    }

    private let viewModel: FilePickerViewModel

    init(viewModel: FilePickerViewModel) {
        self.viewModel = viewModel
    }
}

extension FilePickerController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        viewModel.event(.pickedFile(url))
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
        viewModel.event(.cancelled)
    }
}
