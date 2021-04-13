import UIKit

protocol PopoverPresenter where Self: UIViewController {
    func presentPopover(with style: ItemListStyle,
                        from sourceView: UIView,
                        arrowDirections: UIPopoverArrowDirection,
                        itemSelected: @escaping (ListItemKind) -> Void)
}

extension PopoverPresenter {
    func presentPopover(with style: ItemListStyle,
                        from sourceView: UIView,
                        arrowDirections: UIPopoverArrowDirection,
                        itemSelected: @escaping (ListItemKind) -> Void) {
        let listLiew = ItemListView(with: style)
        listLiew.itemTapped = { itemSelected($0) }
        let controller = PopoverViewController(with: listLiew,
                                               presentFrom: sourceView,
                                               arrowDirections: arrowDirections)
        present(controller, animated: true, completion: nil)
    }
}
