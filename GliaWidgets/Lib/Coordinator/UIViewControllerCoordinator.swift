import UIKit

class UIViewControllerCoordinator: Coordinator {
    typealias Coordinated = UIViewController

    let id = UUID()
    private var children = [UUID: Any]()

    func start() -> Coordinated {
        fatalError("start() must be implemented by subclass")
    }

    /// This method allows us to start child coordinator flows.
    /// Memory management is automatic, meaning, if viewController gets deallocated
    /// coordinator gets freed from memory as well. This is useful in cases where
    /// we don't know when UIViewController will be deallocated (UINavigationController back
    /// button press, dismiss modal controller with swipe down gesture)
    func coordinate<T: UIViewControllerCoordinator>(to coordinator: T) -> Coordinated {
        // Store in memory
        children[coordinator.id] = coordinator

        let viewController = coordinator.start()

        viewController.onDeinit = { [weak self] in
            // Free from memory
            self?.children[coordinator.id] = nil
        }

        return viewController
    }

    deinit {
        children.removeAll()
    }
}
