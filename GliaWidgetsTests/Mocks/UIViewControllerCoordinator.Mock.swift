@testable import GliaWidgets
import UIKit

extension UIViewControllerCoordinator {
    static let mock: UIViewControllerCoordinator = Mock()

    private final class Mock: UIViewControllerCoordinator {
        init() {
            super.init(
                environment: .init(
                    uuid: { UUID() }
                )
            )
        }

        override func start() -> UIViewController {
            UIViewController()
        }
    }
}
