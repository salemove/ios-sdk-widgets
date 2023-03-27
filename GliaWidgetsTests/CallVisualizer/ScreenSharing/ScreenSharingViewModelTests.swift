import XCTest
@testable import GliaWidgets

final class ScreenSharingViewModelTests: XCTestCase {

    private var viewModel: CallVisualizer.ScreenSharingViewModel!

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        viewModel = nil
    }

    func test_end_screen_sharing() throws {
        var isRunning = true
        var screenShareHandlerMock = ScreenShareHandler.mock
        screenShareHandlerMock.stop = { _ in
            isRunning = false
        }

        viewModel = CallVisualizer.ScreenSharingViewModel(
            style: ScreenSharingViewStyle.mock(),
            environment: .init(screenShareHandler: screenShareHandlerMock)
        )

        let props = viewModel.props()

        XCTAssertTrue(isRunning)
        props.screenSharingViewProps.endScreenSharing.tap.execute()
        XCTAssertFalse(isRunning)
    }

    func test_viewModel_output_actions() throws {
        enum Call { case close }
        var calls: [Call] = []

        viewModel = CallVisualizer.ScreenSharingViewModel(
            style: .mock(),
            environment: .init(screenShareHandler: ScreenShareHandler.mock)
        )
        viewModel.delegate = Command { event in
            switch event {
            case .close:
                calls.append(.close)
            }
        }
        let props = viewModel.props()

        props.screenSharingViewProps.endScreenSharing.tap.execute()
        props.screenSharingViewProps.header.backButton?.tap()
        XCTAssertEqual(calls, [.close])
    }
}
