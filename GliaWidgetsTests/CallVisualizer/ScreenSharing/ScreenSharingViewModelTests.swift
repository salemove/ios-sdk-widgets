import XCTest
@testable import GliaWidgets

final class ScreenSharingViewModelTests: XCTestCase {

    private var model: CallVisualizer.ScreenSharingView.Model!

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        model = nil
    }

    func test_end_screen_sharing() throws {
        var isRunning = true
        var screenShareHandlerMock = ScreenShareHandler.mock
        screenShareHandlerMock.stop = { _ in
            isRunning = false
        }

        model = .mock(screenSharingHandler: screenShareHandlerMock)
        XCTAssertTrue(isRunning)
        model.event(.endScreenShareTapped)
        XCTAssertFalse(isRunning)
    }

    func test_viewModel_output_actions() throws {
        enum Call { case close }
        var calls: [Call] = []

        model = .mock()
        model.delegate = Command { event in
            switch event {
            case .closeTapped:
                calls.append(.close)
            }
        }
        model.event(.closeTapped)
        XCTAssertEqual(calls, [.close])
    }
}
