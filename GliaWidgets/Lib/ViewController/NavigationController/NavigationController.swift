import UIKit

class NavigationController: UINavigationController {
    private let transitionDuration: CFTimeInterval = 0.3

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            let transition = CATransition()
            transition.duration = transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromRight
            view.layer.add(transition, forKey: nil)
        }
        
        super.pushViewController(viewController, animated: false)
    }
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if animated {
            let transition = CATransition()
            transition.duration = transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromLeft
            
            view.layer.add(transition, forKey: nil)
        }
        
        return super.popViewController(animated: false)
    }
    
    @discardableResult
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            let transition = CATransition()
            transition.duration = transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromLeft
            
            view.layer.add(transition, forKey: nil)
        }
        
        return super.popToRootViewController(animated: false)
    }
}
