import UIKit

extension UIViewController {
    func insertChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

import UIKit

extension UIViewController {
    private final class DeallocatingProxy {
        var deallocating: (() -> Void)?

        deinit {
            deallocating?()
        }
    }

    private enum AssociatedKeys {
        static var deallocatingProxy = "deallocatingProxy"
    }

    var deallocating: (() -> Void)? {
        get {
            deallocatingProxy?.deallocating
        }
        set {
            if deallocatingProxy == nil {
                deallocatingProxy = DeallocatingProxy()
            }

            deallocatingProxy?.deallocating = newValue
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
