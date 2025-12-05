import XCTest
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

final class VideoCallTests: XCTestCase {
    func test_vc_deinit() {
        weak var weakViewController: CallVisualizer.VideoCallViewController?
        autoreleasepool {
            let viewController: CallVisualizer.VideoCallViewController = .mock()
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "VisitorCodeViewController not deinitilized")
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

    func test_proximityManagerStartsAndStops() {
        enum Call: Equatable { case isIdleTimerDisabled(Bool), isProximityMonitoringEnabled(Bool) }
        var calls: [Call] = []

        let expectation = expectation(description: "AsyncStream finishes immediately")

        DependencyContainer.current.widgets.networkMonitor = .init(networkStream: { replay in
            AsyncStream { continuation in
                continuation.finish()
                expectation.fulfill()
            }
        })

        var env = CallVisualizer.VideoCallViewModel.Environment.mock
        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { value in
            calls.append(.isIdleTimerDisabled(value))
        }
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { value in
            calls.append(.isProximityMonitoringEnabled(value))
        }
        env.proximityManager = .init(environment: proximityManagerEnv)
        var viewModel: CallVisualizer.VideoCallViewModel? = .mock(environment: env)
        let props = viewModel?.makeProps()

        props?.viewDidLoad()

        XCTAssertEqual(calls, [
            .isIdleTimerDisabled(true),
            .isProximityMonitoringEnabled(true)
        ])

        wait(for: [expectation], timeout: 0.1)

        viewModel?.close()
        viewModel = nil

        XCTAssertEqual(calls, [
            .isIdleTimerDisabled(true),
            .isProximityMonitoringEnabled(true),
            .isIdleTimerDisabled(false),
            .isProximityMonitoringEnabled(false)
        ])
    }
}

private extension VideoCallTests {
    func mockViewModel() -> CallVisualizer.VideoCallViewModel {
        let environment = CallVisualizer.VideoCallViewModel.Environment.mock
        return .mock(environment: environment)
    }
}
