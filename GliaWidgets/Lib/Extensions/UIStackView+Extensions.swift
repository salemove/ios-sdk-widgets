import UIKit

extension UIStackView {
    func replaceArrangedSubview(at index: Int, with view: UIView) {
        guard index < arrangedSubviews.count else { return }

        let subview = arrangedSubviews[index]
        removeArrangedSubview(subview)
        subview.removeFromSuperview()

        insertArrangedSubview(view, at: index)
    }

    func replaceArrangedSubviews(with views: [UIView]) {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        addArrangedSubviews(views)
    }

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview(_:))
    }

    func removeArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
