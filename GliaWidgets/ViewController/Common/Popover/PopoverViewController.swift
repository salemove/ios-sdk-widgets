import UIKit

final class PopoverViewController: UIViewController {
    private let contentView: UIView
    private let sourceView: UIView
    private let contentInsets: UIEdgeInsets
    private let minimumWidth: CGFloat

    init(with contentView: UIView,
         presentFrom sourceView: UIView,
         arrowDirection: UIPopoverArrowDirection = .any,
         contentInsets: UIEdgeInsets = .init(top: 15, left: 15, bottom: 15, right: 15),
         minimumWidth: CGFloat = 250) {
        self.contentView = contentView
        self.sourceView = sourceView
        self.contentInsets = contentInsets
        self.minimumWidth = minimumWidth
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceView.bounds
        popoverPresentationController?.permittedArrowDirections = arrowDirection
        popoverPresentationController?.delegate = self
        popoverPresentationController?.passthroughViews = [contentView]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = contentView.backgroundColor
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: contentInsets)
        updatePreferredContentSize()
    }

    private func updatePreferredContentSize() {
        preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

extension PopoverViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
