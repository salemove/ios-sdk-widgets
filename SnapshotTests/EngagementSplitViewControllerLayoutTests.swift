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

    // The chat panel revealed beside a call via the call's chat button. The call
    // keeps its own header controls and chat button; the chat header keeps back
    // only, because the call header owns End.
    func test_callBesideChatPanel() throws {
        let chat = ChatViewController.mockHistoryMessagesScreen()
        chat.setHeaderEndControlsHidden(true)
        let splitViewController = makeSplitViewController(
            panel: chat,
            leading: try CallViewController.mockAudioCallConnectedState(layoutMode: .sidePanel)
        )

        assertPadLandscapeSnapshot(of: splitViewController)
    }

    // The default state during a call: the chat panel is collapsed and the call
    // takes the whole scene.
    func test_callWithChatCollapsed() throws {
        let splitViewController = makeSplitViewController(
            panel: ChatViewController.mockHistoryMessagesScreen(),
            leading: try CallViewController.mockAudioCallConnectedState(layoutMode: .sidePanel)
        )
        splitViewController.setPanelCollapsed(true, animated: false)

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
