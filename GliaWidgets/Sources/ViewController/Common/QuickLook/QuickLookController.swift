import QuickLook

final class QuickLookController: NSObject {
    var viewController: QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = self
        controller.delegate = self
        if let presentationStyle {
            controller.modalPresentationStyle = presentationStyle
        }
        viewModel.environment.log.prefixed(Self.self).info(
            "Create Image Preview screen",
            function: "\(\FilePickerController.viewController)"
        )
        return controller
    }

    private let viewModel: QuickLookViewModel
    /// `nil` keeps `QLPreviewController`'s own default, which is what the
    /// full-screen (iPhone) presentation has always used.
    private let presentationStyle: UIModalPresentationStyle?

    init(
        viewModel: QuickLookViewModel,
        presentationStyle: UIModalPresentationStyle? = nil
    ) {
        self.viewModel = viewModel
        self.presentationStyle = presentationStyle
    }

    deinit {
        viewModel.environment.log.prefixed(Self.self).info("Destroy Image Preview screen")
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
