import UIKit

protocol PopoverPresenter where Self: UIViewController {
    func presentPopover(
        with style: AttachmentSourceListStyle,
        from sourceView: UIView,
        arrowDirections: UIPopoverArrowDirection?,
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    )
}

extension PopoverPresenter {
    func presentPopover(
        with style: AttachmentSourceListStyle,
        from sourceView: UIView,
        arrowDirections: UIPopoverArrowDirection? = nil,
        itemSelected: @escaping (AttachmentSourceItemKind) -> Void
    ) {
        let listView = AttachmentSourceListView(with: style)
        listView.itemTapped = { itemSelected($0) }

        let edgeInsets: UIEdgeInsets

        let adjustedArrowDirection: UIPopoverArrowDirection

        // In case `arrowDirections` is passed, use it as is,
        // otherwise do the figuring out.
        if let arrowDirections {
            adjustedArrowDirection = arrowDirections
        } else {
            // We need to decide how to display `listView`.
            // We can't get size from list view, but
            // know the size of window and position of sourceView
            // in global space. Based on this we can provide arrow directions
            // for popover. For now this are only vertical direction, because
            // it seem sufficient for the given scenarios, but this logic can
            // be adjusted for horizontal direction as well.
            if let window = sourceView.window,
               let globalPosition = sourceView.superview?.convert(sourceView.frame.origin, to: window) {
                if globalPosition.y > window.bounds.midY {
                    adjustedArrowDirection = .down
                } else if globalPosition.y < window.bounds.midY {
                    adjustedArrowDirection = .up
                } else {
                    adjustedArrowDirection = .any
                }
            } else {
                adjustedArrowDirection = .any
            }
        }

        // Depending on single arrowDirection we need to adjust insets.
        // Note, this will work on only *one* item of `arrowDirections` set.
        // For now this seems to be sufficient.
        switch adjustedArrowDirection {
        case .right:
            edgeInsets = .init(top: 0, left: 0, bottom: 0, right: 15)
        case .up:
            edgeInsets = .init(top: 15, left: 0, bottom: -10, right: 0)
        case .down, .any, .unknown:
            edgeInsets = .zero
        default:
            edgeInsets = .zero
        }

        let controller = PopoverViewController(
            with: listView,
            presentFrom: sourceView,
            arrowDirections: adjustedArrowDirection,
            contentInsets: edgeInsets
        )
        present(controller, animated: true, completion: nil)
    }
}
