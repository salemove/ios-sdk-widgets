import UIKit

protocol PopoverPresenter where Self: UIViewController {
    func presentPopover(
        with style: AttachmentSourceListStyle,
        from sourceView: UIView,
        options: [AttachmentSourceItemKind],
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    )
}

extension PopoverPresenter {
    func presentPopover(
        with style: AttachmentSourceListStyle,
        from sourceView: UIView,
        options: [AttachmentSourceItemKind],
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    ) {
        let items = style.items.filter { options.contains($0.kind) }
        // A popover with no items collapses to a zero-height content size, which UIKit
        // then replaces with its own default dimensions, producing a blank sheet with
        // nothing to select. Not presenting at all is the safer outcome.
        guard !items.isEmpty else { return }

        let listView = AttachmentSourceListView(with: style)
        listView.items = items
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
