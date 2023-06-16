import UIKit

final class PopoverViewController: UIViewController {
    private let contentView: UIView
    private let sourceView: UIView
    private let contentInsets: UIEdgeInsets
    private let minimumWidth: CGFloat

    init(with contentView: UIView,
         presentFrom sourceView: UIView,
         arrowDirections: UIPopoverArrowDirection = .any,
         contentInsets: UIEdgeInsets = .zero,
         minimumWidth: CGFloat = 250) {
        self.contentView = contentView
        self.sourceView = sourceView
        self.contentInsets = contentInsets
        self.minimumWidth = minimumWidth
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceView.bounds
        popoverPresentationController?.permittedArrowDirections = arrowDirections
        popoverPresentationController?.delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = contentView.backgroundColor
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentView.layoutInSuperview(insets: contentInsets)
        updatePreferredContentSize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }

    private func updatePreferredContentSize() {
        var size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        if size.width < minimumWidth {
            size.width = minimumWidth
        }

        preferredContentSize = size
    }
}

extension PopoverViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
