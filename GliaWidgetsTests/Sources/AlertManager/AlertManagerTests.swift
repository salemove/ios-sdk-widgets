@testable import GliaWidgets
import XCTest

final class AlertManagerTests: XCTestCase {
    // A `.root` alert raised inside the iPad side panel must dim the panel only.
    func test_rootAlertUsesCurrentContextOnStackThatConfinesAlerts() {
        let navigationController = NavigationController()
        navigationController.confinesAlertsToOwnBounds = true
        let chatScreen = UIViewController()
        navigationController.setViewControllers([chatScreen], animated: false)

        XCTAssertEqual(AlertManager.rootAlertPresentationStyle(for: chatScreen), .overCurrentContext)
    }

    // `UINavigationController` defines a presentation context by default, so the
    // decision must come from the explicit flag, or every iPhone alert would change.
    func test_rootAlertCoversWindowOnOrdinaryStack() {
        let navigationController = NavigationController()
        XCTAssertTrue(navigationController.definesPresentationContext)
        let chatScreen = UIViewController()
        navigationController.setViewControllers([chatScreen], animated: false)

        XCTAssertEqual(AlertManager.rootAlertPresentationStyle(for: chatScreen), .overFullScreen)
        XCTAssertEqual(AlertManager.rootAlertPresentationStyle(for: UIViewController()), .overFullScreen)
    }
}
