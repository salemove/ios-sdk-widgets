import XCTest
@testable import GliaWidgets

final class EngagementLayoutModeTests: XCTestCase {
    func test_resolvesSidePanelForPadAtOrAboveMinimumWidth() {
        XCTAssertEqual(
            EngagementLayoutMode.resolve(idiom: .pad, sceneWidth: EngagementLayoutMode.sidePanelMinimumSceneWidth),
            .sidePanel
        )
        XCTAssertEqual(
            EngagementLayoutMode.resolve(idiom: .pad, sceneWidth: 1_024),
            .sidePanel
        )
    }

    func test_resolvesFullScreenForPadBelowMinimumWidth() {
        XCTAssertEqual(
            EngagementLayoutMode.resolve(
                idiom: .pad,
                sceneWidth: EngagementLayoutMode.sidePanelMinimumSceneWidth - 1
            ),
            .fullScreen
        )
    }

    func test_resolvesFullScreenForPhoneRegardlessOfWidth() {
        XCTAssertEqual(
            EngagementLayoutMode.resolve(idiom: .phone, sceneWidth: 1_024),
            .fullScreen
        )
    }

    func test_resolvesFullScreenForNilWindowScene() {
        XCTAssertEqual(EngagementLayoutMode.resolve(for: nil), .fullScreen)
    }
}
