@testable import GliaWidgets
import XCTest

final class EngagementPanelWindowTests: XCTestCase {
    private var hostWindow: UIWindow?
    private var panelWindow: EngagementPanelWindow?

    override func tearDown() {
        panelWindow?.isHidden = true
        hostWindow?.isHidden = true
        panelWindow = nil
        hostWindow = nil
        super.tearDown()
    }

    func test_panelWindowSitsJustAboveHostWindow() {
        let panelWindow = EngagementPanelWindow(frame: .zero)
        XCTAssertEqual(panelWindow.windowLevel, .normal + 1)
        XCTAssertTrue(panelWindow is GliaOwnedWindow)
    }

    func test_hitTestPassesThroughPointsOverEmptyRegion() {
        let (panelWindow, splitViewController) = makeVisiblePanelWindow(width: 1024, height: 768)
        let panel = UIViewController()
        panel.view.backgroundColor = .white
        splitViewController.setPanel(panel)
        panelWindow.layoutIfNeeded()

        XCTAssertNil(panelWindow.hitTest(CGPoint(x: 100, y: 100), with: nil))
    }

    func test_hitTestReturnsGliaContentOverPanel() {
        let (panelWindow, splitViewController) = makeVisiblePanelWindow(width: 1024, height: 768)
        let panel = UIViewController()
        panel.view.backgroundColor = .white
        splitViewController.setPanel(panel)
        panelWindow.layoutIfNeeded()

        XCTAssertTrue(panelWindow.hitTest(CGPoint(x: 1000, y: 100), with: nil) === panel.view)
    }

    // A direct call installs the call screen before the panel window is shown,
    // i.e. before the split container's view loads. Its controls must still be
    // reachable afterwards, otherwise every tap on the call pane falls through
    // to the host app.
    func test_hitTestReturnsCallContentWhenLeadingWasSetBeforeViewLoaded() {
        let panelWindow = EngagementPanelWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        let splitViewController = EngagementSplitViewController()
        let leading = UIViewController()
        leading.view.backgroundColor = .black
        splitViewController.setLeading(leading)
        XCTAssertFalse(splitViewController.isViewLoaded)

        panelWindow.rootViewController = splitViewController
        panelWindow.isHidden = false
        panelWindow.layoutIfNeeded()
        self.panelWindow = panelWindow

        XCTAssertTrue(panelWindow.hitTest(CGPoint(x: 100, y: 100), with: nil) === leading.view)
    }

    func test_hitTestPassesThroughAgainAfterLeadingIsCleared() {
        let (panelWindow, splitViewController) = makeVisiblePanelWindow(width: 1024, height: 768)
        let leading = UIViewController()
        leading.view.backgroundColor = .black
        splitViewController.setLeading(leading)
        panelWindow.layoutIfNeeded()
        XCTAssertTrue(panelWindow.hitTest(CGPoint(x: 100, y: 100), with: nil) === leading.view)

        splitViewController.setLeading(nil)
        panelWindow.layoutIfNeeded()

        XCTAssertNil(panelWindow.hitTest(CGPoint(x: 100, y: 100), with: nil))
    }

    // Two live windows in one scene share one keyboard: the panel takes key
    // status while the visitor uses it, and must hand it back to the host window
    // that had it — not just any host window.
    func test_resignKeyToHostWindowRestoresPreviouslyKeyHostWindow() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let hostWindow = UIWindow(windowScene: scene)
        hostWindow.rootViewController = UIViewController()
        hostWindow.makeKeyAndVisible()
        self.hostWindow = hostWindow

        let panelWindow = EngagementPanelWindow(windowScene: scene)
        panelWindow.rootViewController = EngagementSplitViewController()
        panelWindow.isHidden = false
        self.panelWindow = panelWindow

        panelWindow.takeKeyFromHostWindow()
        XCTAssertTrue(panelWindow.isKeyWindow)

        panelWindow.resignKeyToHostWindow()

        XCTAssertFalse(panelWindow.isKeyWindow)
        XCTAssertTrue(hostWindow.isKeyWindow)
    }

    func test_resignKeyToHostWindowIsNoOpWhenPanelIsNotKey() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let hostWindow = UIWindow(windowScene: scene)
        hostWindow.rootViewController = UIViewController()
        hostWindow.makeKeyAndVisible()
        self.hostWindow = hostWindow

        let panelWindow = EngagementPanelWindow(windowScene: scene)
        panelWindow.rootViewController = EngagementSplitViewController()
        panelWindow.isHidden = false
        self.panelWindow = panelWindow

        panelWindow.resignKeyToHostWindow()

        XCTAssertTrue(hostWindow.isKeyWindow)
    }
}

private extension EngagementPanelWindowTests {
    func makeVisiblePanelWindow(
        width: CGFloat,
        height: CGFloat
    ) -> (EngagementPanelWindow, EngagementSplitViewController) {
        let panelWindow = EngagementPanelWindow(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let splitViewController = EngagementSplitViewController()
        panelWindow.rootViewController = splitViewController
        panelWindow.isHidden = false
        panelWindow.layoutIfNeeded()
        self.panelWindow = panelWindow
        return (panelWindow, splitViewController)
    }
}
