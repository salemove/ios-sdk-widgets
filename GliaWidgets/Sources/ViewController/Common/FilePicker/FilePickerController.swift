import UIKit
import UniformTypeIdentifiers

final class FilePickerController: NSObject {
    var viewController: UIViewController {
        let contentTypes = viewModel.allowedFiles.types.compactMap { UTType($0) }
        let safeTypes = contentTypes.isEmpty ? [.data] : contentTypes
        let urls = environment.fileManager.urlsForDirectoryInDomainMask(.documentDirectory, .userDomainMask)

        return environment.documentPicker.make(safeTypes, urls.first, self)
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
