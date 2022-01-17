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
        if rootViewController == nil {
            fatalError("Attempting to use presenter with deallocated view")
        }

        presented.append(view)

        let presentOn = (getSourceToPresentOn() ?? rootViewController)
        presentOn?.present(view, animated: animated, completion: completion)
    }

    func dismiss(view: UIViewController?, animated: Bool, completion: (() -> Void)?) {
        if let view = view,
            let index = index(of: view),
            let viewController = presented[safe: index] {
                viewController.presentingViewController?
                    .dismiss(animated: animated, completion: { [weak self] in
                        if viewController.view.window == nil {
                            completion?()
                            self?.presented.remove(at: index)
                        }
                    })
        }
    }

    public func dismissAll(animated: Bool, completion: (() -> Void)?) {
        if let viewController = presented.first {
            viewController.presentingViewController?
                .dismiss(animated: animated, completion: { [weak self] in
                    completion?()
                    self?.presented.removeAll()
                })
        }
    }

    private func getSourceToPresentOn() -> UIViewController? {
        return presented
            .filter({ isInWindowHierarchy($0) })
            .filter({ !isBeingDismissed($0) })
            .last
    }

    private func isInWindowHierarchy(_ viewController: UIViewController) -> Bool {
        return viewController.view.window != nil
    }

    private func isBeingDismissed(_ viewController: UIViewController) -> Bool {
        return viewController.isBeingDismissed
    }

    private func index(of view: UIViewController) -> Int? {
        return presented.firstIndex(where: { $0 == view })
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index)
            ? self[index]
            : nil
    }
}
