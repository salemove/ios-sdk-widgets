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
        var props: CallVisualizer.ScreenSharingViewModel.Props = .initial

        viewModel = CallVisualizer.ScreenSharingViewModel(
            style: ScreenSharingViewStyle.mock(),
            delegate: Command { event in
                guard case let .propsUpdated(updatedProps) = event else { return }
                props = updatedProps
            },
            environment: .init(screenShareHandler: screenShareHandlerMock)
        )

        XCTAssertEqual(screenShareHandlerMock.status.value, .started)
        props.screenSharingViewProps.endScreenSharing()
        XCTAssertEqual(screenShareHandlerMock.status.value, .stopped)
    }

    func test_viewModel_output_actions() throws {
        enum Call { case close }
        var calls: [Call] = []
        var props: CallVisualizer.ScreenSharingViewModel.Props = .initial

        viewModel = CallVisualizer.ScreenSharingViewModel(
            style: .mock(),
            delegate: Command { event in
                switch event {
                case .close:
                    calls.append(.close)

                case let .propsUpdated(updatedProps):
                    props = updatedProps
                }
            },
            environment: .init(screenShareHandler: ScreenShareHandler.mock())
        )

        props.screenSharingViewProps.endScreenSharing()
        XCTAssertEqual(calls, [.close])

        props.screenSharingViewProps.back()
        XCTAssertEqual(calls, [.close, .close])
    }
}
