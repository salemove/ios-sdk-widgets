import UIKit

protocol PopoverPresenter where Self: UIViewController {
    func presentPopover(
        with style: AttachmentSourceListStyle,
        from sourceView: UIView,
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    )
}

extension PopoverPresenter {
    func presentPopover(
        with style: AttachmentSourceListStyle,
        from sourceView: UIView,
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    ) {
        let listView = AttachmentSourceListView(with: style)
        listView.itemTapped = { itemSelected($0) }

        let edgeInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 15)
        let controller = PopoverViewController(
            with: listView,
            presentFrom: sourceView,
            contentInsets: edgeInsets
        )
        present(controller, animated: true, completion: nil)
    }
}
