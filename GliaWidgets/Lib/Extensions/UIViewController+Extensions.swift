import UIKit

extension UIViewController {
    func insertChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

extension UIViewController {
    private final class DeallocatingProxy {
        var onDeinit: (() -> Void)?

        deinit {
            onDeinit?()
        }
    }

    private enum AssociatedKeys {
        static var deallocatingProxy = "deallocatingProxy"
    }

    var onDeinit: (() -> Void)? {
        get {
            deallocatingProxy?.onDeinit
        }
        set {
            if deallocatingProxy == nil {
                deallocatingProxy = DeallocatingProxy()
            }

            deallocatingProxy?.onDeinit = newValue
        }
    }

    private var deallocatingProxy: DeallocatingProxy? {
        get {
            objc_getAssociatedObject(
                self,
                &AssociatedKeys.deallocatingProxy
            ) as? DeallocatingProxy
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.deallocatingProxy,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
