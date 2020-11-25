import UIKit

internal extension UITableView {
    func register<T: UITableViewCell>(cell type: T.Type) {
        register(type, forCellReuseIdentifier: String(describing: T.self))
    }

    func deque<T: UITableViewCell>(cellFor indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(
            withIdentifier: String(describing: T.self),
            for: indexPath
        ) as! T
    }

    func register<T: UITableViewHeaderFooterView>(headerFooterView type: T.Type) {
        register(type, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    func dequeHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        // swiftlint:disable force_cast
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as! T
    }

    func scrollToBottom(animated: Bool) {
        guard numberOfRows(inSection: 0) > 0 else { return }

        let rowCount = numberOfRows(inSection: 0)
        let indexPath = IndexPath(row: rowCount - 1, section: 0)

        DispatchQueue.main.async { [weak self] in
            self?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    func scrollToTop(animated: Bool) {
        guard numberOfRows(inSection: 0) > 0 else { return }
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}
