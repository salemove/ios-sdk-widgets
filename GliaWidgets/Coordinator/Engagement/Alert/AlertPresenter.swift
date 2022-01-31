import UIKit

final class AlertPresenter {
    private var presented: [UIViewController] = []

    private weak var rootViewController: UIViewController?

    init(rootViewController: UIViewController? = nil) {
        self.rootViewController = rootViewController
    }

    deinit {
        dismissAll(animated: false, completion: nil)
    }

    func present(view: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard rootViewController != nil else {
            assertionFailure("Attempting to use presenter with deallocated view")
            return
        }

        let presentOn = getSourceToPresentOn() ?? rootViewController
        presentOn?.present(view, animated: animated, completion: completion)
    }

    func dismiss(view: UIViewController?, animated: Bool, completion: (() -> Void)?) {
        guard
            let view = view,
            let index = index(of: view),
            let viewController = presented[safe: index]
        else { return }

        viewController.presentingViewController?.dismiss(animated: animated) { [weak self] in
            if viewController.view.window == nil {
                completion?()
                self?.presented.remove(at: index)
            }
        }
    }

    public func dismissAll(animated: Bool, completion: (() -> Void)?) {
        guard let viewController = presented.first else { return }

        viewController.presentingViewController?.dismiss(animated: animated) { [weak self] in
            completion?()
            self?.presented.removeAll()
        }
    }

    private func getSourceToPresentOn() -> UIViewController? {
        presented
            .filter { isInWindowHierarchy($0) }
            .filter { !isBeingDismissed($0) }
            .last
    }

    private func isInWindowHierarchy(_ viewController: UIViewController) -> Bool {
        viewController.view.window != nil
    }

    private func isBeingDismissed(_ viewController: UIViewController) -> Bool {
        viewController.isBeingDismissed
    }

    private func index(of view: UIViewController) -> Int? {
        presented.firstIndex(where: { $0 == view })
    }
}
