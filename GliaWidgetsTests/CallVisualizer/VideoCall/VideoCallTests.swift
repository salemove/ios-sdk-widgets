import XCTest
@testable import GliaWidgets

final class VideoCallTests: XCTestCase {
    func test_vc_deinit() {
        weak var weakViewController: CallVisualizer.VideoCallViewController?
        autoreleasepool {
            let viewController = CallVisualizer.VideoCallViewController(
                props: .init(videoCallViewProps: .mock),
                environment: .mock
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "VisitorCodeViewController not deinitilized")
    }
    func test_end_screen_sharing() {
        let viewModel: CallVisualizer.VideoCallViewModel = .mock()
        viewModel.environment.screenShareHandler.status.value = .started

        let headerProps: Header.Props = .init(
            title: "",
            effect: .none,
            endButton: .init(),
            backButton: .init(style: .mock()),
            closeButton: .init(style: .mock()),
            endScreenshareButton: .init(
                tap: .init { _ in
                    viewModel.environment.screenShareHandler.stop()
                },
                style: .mock(),
                size: .zero
            ),
            style: .mock()
        )

        XCTAssertEqual(viewModel.environment.screenShareHandler.status.value, .started)
        headerProps.endScreenshareButton.tap.execute()
        XCTAssertEqual(viewModel.environment.screenShareHandler.status.value, .stopped)
    }

    func test_video_button_action() {
        var wasExecuted: Bool = false
        let buttonBarProps = CallVisualizer.VideoCallView.CallButtonBar.Props(
            style: .mock,
            videoButtonTap: .init { _ in
                wasExecuted = true
            },
            minimizeTap: .nop
        )

        buttonBarProps.videoButtonTap.execute()
        XCTAssertEqual(wasExecuted, true)
    }

    func test_minimize_button_action() {
        var wasExecuted: Bool = false
        let buttonBarProps = CallVisualizer.VideoCallView.CallButtonBar.Props(
            style: .mock,
            videoButtonTap: .nop,
            minimizeTap: .init { _ in
                wasExecuted = true
            }
        )

        buttonBarProps.minimizeTap.execute()
        XCTAssertEqual(wasExecuted, true)
    }

    func test_back_button_action() {
        var wasExecuted: Bool = false
        let headerProps: Header.Props = .init(
            title: "",
            effect: .none,
            endButton: .init(),
            backButton: .init(
                tap: .init { _ in
                    wasExecuted = true
                },
                style: .mock(),
                size: .zero
            ),
            closeButton: .init(style: .mock()),
            endScreenshareButton: .init(style: .mock()),
            style: .mock()
        )

        headerProps.backButton.tap.execute()
        XCTAssertEqual(wasExecuted, true)
    }
}
