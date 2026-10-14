import UIKit

extension ChatView {
    func setupOlderHistoryRefreshControl() {
        olderHistoryRefreshControl.tintColor = style.olderMessagesIndicatorColor
        olderHistoryRefreshControl.addAction(
            UIAction { [weak self] _ in self?.loadOlderHistoryRequested?() },
            for: .valueChanged
        )
    }

    func setOlderHistoryState(canLoad: Bool, isLoading: Bool) {
        // Detached rather than disabled: `UIRefreshControl` has no enabled state that also
        // stops the pull gesture from showing the spinner.
        let isPullToLoadAvailable = canLoad || isLoading
        if isPullToLoadAvailable, tableView.refreshControl == nil {
            tableView.refreshControl = olderHistoryRefreshControl
        }
        if !isLoading, olderHistoryRefreshControl.isRefreshing {
            olderHistoryRefreshControl.endRefreshing()
        }
        if !isPullToLoadAvailable, tableView.refreshControl != nil {
            tableView.refreshControl = nil
        }
    }

    func prependRows(_ count: Int, to section: Int) {
        guard let rows = numberOfRows?(section), rows >= count, count > 0 else { return }
        let previousContentHeight = tableView.contentSize.height
        let previousOffsetY = tableView.contentOffset.y
        UIView.performWithoutAnimation {
            // Same crash workarounds as `appendRows`: batch updates crash on a zero-sized table
            // view and inserting with no visible cells can crash, so fall back to a full reload.
            if tableView.visibleCells.isEmpty {
                tableView.reloadData()
            } else {
                let indexPaths = (0 ..< count).map { IndexPath(row: $0, section: section) }
                if tableView.frame.size == .zero {
                    tableView.insertRows(at: indexPaths, with: .none)
                } else {
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: indexPaths, with: .none)
                    }
                }
            }
            tableView.layoutIfNeeded()
        }
        // Rows are inserted above the visible ones, so shift the offset by the added height to
        // keep what the visitor was reading in place instead of jumping to the new top.
        tableView.contentOffset.y = previousOffsetY + (tableView.contentSize.height - previousContentHeight)
        UIAccessibility.post(
            notification: .announcement,
            argument: Localization.Chat.OlderMessagesLoaded.Accessibility.announcement
        )
    }
}
