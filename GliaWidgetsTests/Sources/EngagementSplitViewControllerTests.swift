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
