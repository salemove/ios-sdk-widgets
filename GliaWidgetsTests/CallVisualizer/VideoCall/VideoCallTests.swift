import XCTest
@testable import GliaWidgets

final class VideoCallTests: XCTestCase {
    func test_vc_deinit() {
        weak var weakViewController: CallVisualizer.VideoCallViewController?
        autoreleasepool {
            let viewController: CallVisualizer.VideoCallViewController = .mock()
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "VisitorCodeViewController not deinitilized")
    }

    func test_end_screen_sharing() {
        let viewModel: CallVisualizer.VideoCallViewModel = .mock()
        viewModel.environment.screenShareHandler.status.value = .started

        let headerProps: Header.Props = .mock(
            endScreenShareButton: .init(
                tap: .init { _ in
                    viewModel.environment.screenShareHandler.stop()
                },
                style: .mock()
            )
        )

        XCTAssertEqual(viewModel.environment.screenShareHandler.status.value, .started)
        headerProps.endScreenshareButton.tap()
        XCTAssertEqual(viewModel.environment.screenShareHandler.status.value, .stopped)
    }

    func test_video_button_action() {
        var wasExecuted: Bool = false
        let buttonBarProps: CallVisualizer.VideoCallView.CallButtonBar.Props = .mock(
            videoButtonTap: .init { _ in
                wasExecuted = true
            }
        )

        buttonBarProps.videoButtonTap()
        XCTAssertEqual(wasExecuted, true)
    }

    func test_minimize_button_action() {
        var wasExecuted: Bool = false
        let buttonBarProps: CallVisualizer.VideoCallView.CallButtonBar.Props = .mock(
            minimizeTap: .init { _ in
                wasExecuted = true
            }
        )

        buttonBarProps.minimizeTap()
        XCTAssertEqual(wasExecuted, true)
    }

    func test_back_button_action() {
        var wasExecuted: Bool = false
        let headerProps: Header.Props = .mock(
            backButton: .init(
                tap: .init { _ in
                    wasExecuted = true
                },
                style: .mock()
            )
        )

        headerProps.backButton?.tap()
        XCTAssertEqual(wasExecuted, true)
    }
}
