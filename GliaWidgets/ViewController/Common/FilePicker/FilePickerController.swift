import UIKit

final class FilePickerController: NSObject {
    var viewController: UIDocumentPickerViewController {
        if let documentPicker = documentPicker { return documentPicker }
        let documentPicker = UIDocumentPickerViewController(documentTypes: viewModel.allowedFiles.types, in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        self.documentPicker = documentPicker
        return documentPicker
    }

    private let viewModel: FilePickerViewModel
    private var documentPicker: UIDocumentPickerViewController?

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
        documentPicker = nil
    }
}
