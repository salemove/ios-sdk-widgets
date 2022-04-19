import UIKit

class UIViewControllerCoordinator: Coordinator {
    lazy var id: UUID = environment.uuid()

    var children = [UUID: UIViewControllerCoordinator]()

    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func start() -> UIViewController {
        fatalError("start() must be implemented by subclass")
    }

    /// This method allows us to start child coordinator flows.
    /// Memory management is automatic, meaning, if viewController gets deallocated
    /// coordinator gets freed from memory as well. This is useful in cases where
    /// we don't know when UIViewController will be deallocated (UINavigationController back
    /// button press, dismiss modal controller with swipe down gesture)
    func coordinate<T: UIViewControllerCoordinator>(to coordinator: T) -> UIViewController {
        store(coordinator)

        return free(coordinator)
    }

    private func store(_ coordinator: UIViewControllerCoordinator) {
        children[coordinator.id] = coordinator
    }

    private func free(_ coordinator: UIViewControllerCoordinator) -> UIViewController {
        let viewController = coordinator.start()

        viewController.onDeinit = { [weak self] in
            self?.children[coordinator.id] = nil
        }

        return viewController
    }

    deinit {
        children.removeAll()
    }
}

extension UIViewControllerCoordinator {
    struct Environment {
        var uuid: () -> UUID
    }
}

extension UIViewControllerCoordinator: Equatable {
    static func == (lhs: UIViewControllerCoordinator, rhs: UIViewControllerCoordinator) -> Bool {
        lhs.id == rhs.id
    }
}

extension UIViewController {
    private final class DeinitProxy {
        var onDeinit: (() -> Void)?

        deinit {
            onDeinit?()
        }
    }

    private enum AssociatedKeys {
        static var deinitProxy = "DeinitProxy"
    }

    var onDeinit: (() -> Void)? {
        get {
            proxy?.onDeinit
        }
        set {
            if proxy == nil {
                proxy = DeinitProxy()
            }

            proxy?.onDeinit = newValue
        }
    }

    private var proxy: DeinitProxy? {
        get {
            objc_getAssociatedObject(
                self,
                &AssociatedKeys.deinitProxy
            ) as? DeinitProxy
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.deinitProxy,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
