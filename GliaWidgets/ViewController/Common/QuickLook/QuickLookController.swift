import QuickLook

final class QuickLookController: NSObject {
    var viewController: QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.delegate = self
        return controller
    }

    private let viewModel: QuickLookViewModel

    init(viewModel: QuickLookViewModel) {
        self.viewModel = viewModel
    }
}

extension QuickLookController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return viewModel.numOfItems
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return viewModel.item(at: index)
    }
}

extension QuickLookController: QLPreviewControllerDelegate {
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        viewModel.event(.dismissed)
    }
}
