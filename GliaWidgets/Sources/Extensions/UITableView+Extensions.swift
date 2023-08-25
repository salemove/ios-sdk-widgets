import UIKit

internal extension UITableView {
    func register<T: UITableViewCell>(cell type: T.Type) {
        register(type, forCellReuseIdentifier: String(describing: T.self))
    }

    func dequeue<T: UITableViewCell>(cellFor indexPath: IndexPath) -> T? {
        return dequeueReusableCell(
            withIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T
    }

    func register<T: UITableViewHeaderFooterView>(headerFooterView type: T.Type) {
        register(type, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T
    }

    func scrollToBottom(animated: Bool) {
        // Perform calculations on the main thread to prevent potential race conditions.
        // There's a possibility that the section and row counts could change during the
        // calculation process. If not handled, this could lead to an attempt to scroll
        // out-of-bounds, resulting in a crash.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Identify the last section with at least one row.
            let section = (0..<self.numberOfSections)
                .reversed()
                .first { self.numberOfRows(inSection: $0) > 0 }

            guard let validSection = section else { return }
            let rowCount = self.numberOfRows(inSection: validSection)

            // Ensure there's at least one row in the identified section.
            guard rowCount >= 1 else { return }

            let lastRowIndex = rowCount - 1
            let indexPath = IndexPath(row: lastRowIndex, section: validSection)

            self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}
