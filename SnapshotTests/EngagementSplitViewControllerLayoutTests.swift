@testable import GliaWidgets
import SnapshotTesting
import XCTest

/// Locks the iPad side-panel geometry itself: a 400pt trailing panel with the
/// leading region either empty (transparent to the host app) or occupied by
/// the call screen. Chat-content snapshots live in `ChatViewControllerLayoutTests`.
final class EngagementSplitViewControllerLayoutTests: SnapshotTestCase {
    func test_chatOnlyPanel() {
        let splitViewController = makeSplitViewController(
            panel: ChatViewController.mockHistoryMessagesScreen()
        )

        assertPadLandscapeSnapshot(of: splitViewController)
    }

    // In panel mode the call header hides back/end and the button bar drops the
    // chat button, because the chat panel beside it already provides them.
    func test_callBesideChatPanel() throws {
        let splitViewController = makeSplitViewController(
            panel: ChatViewController.mockHistoryMessagesScreen(),
            leading: try CallViewController.mockAudioCallConnectedState(layoutMode: .sidePanel)
        )

        assertPadLandscapeSnapshot(of: splitViewController)
    }

    private func makeSplitViewController(
        panel: UIViewController,
        leading: UIViewController? = nil
    ) -> EngagementSplitViewController {
        let navigationController = NavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.setViewControllers([panel], animated: false)

        let splitViewController = EngagementSplitViewController()
        splitViewController.setPanel(navigationController)
        splitViewController.setLeading(leading)
        return splitViewController
    }

    private func assertPadLandscapeSnapshot(
        of viewController: UIViewController,
        file: StaticString = #file,
        functionName: String = #function,
        line: UInt = #line
    ) {
        viewController.view.bounds = CGRect(origin: .zero, size: SnapshotTestCase.padLandscapeSize)
        SnapshotTesting.assertSnapshot(
            matching: viewController,
            as: .imagePadLandscape,
            named: nameForDevice("padLandscape"),
            file: file,
            testName: functionName,
            line: line
        )
    }
}
