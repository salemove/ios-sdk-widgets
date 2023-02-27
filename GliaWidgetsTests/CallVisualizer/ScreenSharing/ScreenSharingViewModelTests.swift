import XCTest
@testable import GliaWidgets

final class ScreenSharingViewModelTests: XCTestCase {

    private var viewModel: CallVisualizer.ScreenSharingViewModel!

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        viewModel = nil
    }

    func test_end_screen_sharing() throws {
        let screenShareHandlerMock = ScreenShareHandler.mock()
        screenShareHandlerMock.status.value = .started

        viewModel = CallVisualizer.ScreenSharingViewModel(
            style: ScreenSharingViewStyle.mock(),
            environment: .init(screenShareHandler: screenShareHandlerMock)
        )

        let props = viewModel.props()

        XCTAssertEqual(screenShareHandlerMock.status.value, .started)
        props.screenSharingViewProps.endScreenSharing.tap.execute()
        XCTAssertEqual(screenShareHandlerMock.status.value, .stopped)
    }

    func test_viewModel_output_actions() throws {
        enum Call { case close }
        var calls: [Call] = []

        viewModel = CallVisualizer.ScreenSharingViewModel(
            style: .mock(),
            environment: .init(screenShareHandler: ScreenShareHandler.mock())
        )
        viewModel.delegate = Command { event in
            switch event {
            case .close:
                calls.append(.close)
            }
        }
        let props = viewModel.props()

        props.screenSharingViewProps.endScreenSharing.tap.execute()
        XCTAssertEqual(calls, [.close])

        props.screenSharingViewProps.header.backButton?.tap()
        XCTAssertEqual(calls, [.close, .close])
    }
}
