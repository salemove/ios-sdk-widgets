@testable import GliaWidgets
import XCTest

final class EngagementSplitViewControllerTests: XCTestCase {
    func test_panelKeepsFixedWidthAtOrAboveSidePanelThreshold() {
        XCTAssertEqual(EngagementSplitViewController.panelWidth(forSceneWidth: 768), 400)
        XCTAssertEqual(EngagementSplitViewController.panelWidth(forSceneWidth: 1024), 400)
        XCTAssertEqual(EngagementSplitViewController.panelWidth(forSceneWidth: 1366), 400)
    }

    // Below the threshold the panel takes the whole window, matching today's
    // full-screen presentation and making the window opaque to touches.
    func test_panelFillsWindowBelowSidePanelThreshold() {
        XCTAssertEqual(EngagementSplitViewController.panelWidth(forSceneWidth: 767), 767)
        XCTAssertEqual(EngagementSplitViewController.panelWidth(forSceneWidth: 507), 507)
        XCTAssertEqual(EngagementSplitViewController.panelWidth(forSceneWidth: 320), 320)
    }

    func test_layoutAppliesClampedPanelWidthFromViewBounds() {
        let splitViewController = EngagementSplitViewController()
        splitViewController.view.frame = CGRect(x: 0, y: 0, width: 507, height: 800)
        let panel = UIViewController()
        splitViewController.setPanel(panel)

        splitViewController.view.layoutIfNeeded()

        XCTAssertEqual(panel.view.frame.width, 507)

        splitViewController.view.frame = CGRect(x: 0, y: 0, width: 1024, height: 768)
        splitViewController.view.layoutIfNeeded()

        XCTAssertEqual(panel.view.frame.width, 400)
        let panelFrameInSplitView = panel.view.convert(panel.view.bounds, to: splitViewController.view)
        XCTAssertEqual(panelFrameInSplitView.maxX, 1024)
    }

    func test_clearingLeadingDisablesLeadingInteraction() {
        let splitViewController = EngagementSplitViewController()
        splitViewController.loadViewIfNeeded()
        let leading = UIViewController()

        splitViewController.setLeading(leading)
        XCTAssertTrue(splitViewController.leadingViewController === leading)
        XCTAssertNotNil(leading.parent)

        splitViewController.setLeading(nil)
        XCTAssertNil(splitViewController.leadingViewController)
        XCTAssertNil(leading.parent)
    }
}

// MARK: - Collapsing the panel behind a call
extension EngagementSplitViewControllerTests {
    func test_collapsedPanelHasZeroWidthAndLeadingFillsTheScene() {
        let splitViewController = EngagementSplitViewController()
        splitViewController.view.frame = CGRect(x: 0, y: 0, width: 1024, height: 768)
        let panel = UIViewController()
        let leading = UIViewController()
        splitViewController.setPanel(panel)
        splitViewController.setLeading(leading)

        splitViewController.setPanelCollapsed(true, animated: false)

        XCTAssertTrue(splitViewController.isPanelCollapsed)
        XCTAssertEqual(panel.view.frame.width, 0)
        XCTAssertEqual(leading.view.frame.width, 1024)

        // A size change must not re-apply the regular panel width while collapsed.
        splitViewController.view.frame = CGRect(x: 0, y: 0, width: 1366, height: 1024)
        splitViewController.view.layoutIfNeeded()
        XCTAssertEqual(panel.view.frame.width, 0)
        XCTAssertEqual(leading.view.frame.width, 1366)

        splitViewController.setPanelCollapsed(false, animated: false)

        XCTAssertFalse(splitViewController.isPanelCollapsed)
        XCTAssertEqual(panel.view.frame.width, 400)
        XCTAssertEqual(leading.view.frame.width, 966)
    }

    // The window stays visible while the panel collapses, so the container has
    // to tell the chat itself that it went off screen — that is what flips the
    // chat view model's active flag and lets unread messages be counted.
    func test_collapsingAndRevealingForwardAppearanceToPanelContent() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        addTeardownBlock { window.isHidden = true }
        let splitViewController = EngagementSplitViewController()
        let panel = AppearanceRecordingViewController()
        let leading = AppearanceRecordingViewController()
        splitViewController.setPanel(panel)
        splitViewController.setLeading(leading)
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        waitUntil { panel.events.contains(.didAppear) }
        XCTAssertEqual(panel.events, [.willAppear, .didAppear])
        XCTAssertEqual(leading.events, [.willAppear, .didAppear])

        splitViewController.setPanelCollapsed(true, animated: false)
        XCTAssertEqual(panel.events.suffix(2), [.willDisappear, .didDisappear])
        XCTAssertEqual(leading.events.count, 2)

        splitViewController.setPanelCollapsed(false, animated: false)
        XCTAssertEqual(panel.events.suffix(2), [.willAppear, .didAppear])
    }

    func test_collapsedPanelDoesNotAppearWhenWindowBecomesVisible() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        addTeardownBlock { window.isHidden = true }
        let splitViewController = EngagementSplitViewController()
        let panel = AppearanceRecordingViewController()
        let leading = AppearanceRecordingViewController()
        splitViewController.setPanel(panel)
        splitViewController.setLeading(leading)
        splitViewController.setPanelCollapsed(true, animated: false)
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        waitUntil { leading.events.contains(.didAppear) }

        XCTAssertEqual(leading.events, [.willAppear, .didAppear])
        XCTAssertTrue(panel.events.isEmpty)
    }

    private func waitUntil(timeout: TimeInterval = 2, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
    }
}

private final class AppearanceRecordingViewController: UIViewController {
    enum Event { case willAppear, didAppear, willDisappear, didDisappear }
    var events: [Event] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        events.append(.willAppear)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        events.append(.didAppear)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        events.append(.willDisappear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        events.append(.didDisappear)
    }
}
