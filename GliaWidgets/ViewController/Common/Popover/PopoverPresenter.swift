import UIKit

protocol PopoverPresenter where Self: UIViewController {
    func presentPopover(with style: AttachmentSourceListStyle,
                        from sourceView: UIView,
                        arrowDirections: UIPopoverArrowDirection,
                        itemSelected: @escaping (AttachmentSourceItemKind) -> Void)
}

extension PopoverPresenter {
    func presentPopover(with style: AttachmentSourceListStyle,
                        from sourceView: UIView,
                        arrowDirections: UIPopoverArrowDirection,
                        itemSelected: @escaping (AttachmentSourceItemKind) -> Void) {
        let listLiew = AttachmentSourceListView(with: style)
        listLiew.itemTapped = { itemSelected($0) }
        let controller = PopoverViewController(with: listLiew,
                                               presentFrom: sourceView,
                                               arrowDirections: arrowDirections)
        present(controller, animated: true, completion: nil)
    }
}
