@testable import GliaWidgets
import XCTest

class CallViewControllerTests: XCTestCase {
    func test_call_deinit() {
        weak var weakViewController: CallViewController?
        autoreleasepool {
            let viewController: CallViewController? = CallViewController(
                viewModel: CallViewModel.mock(environment: CallViewModel.Environment.mock),
                environment: .mock()
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "CallViewController not deinitilized")
    }

    @MainActor
    func testLiveObservationIndicatorIsPresented() async throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { [] }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true
        )
        viewModelEnv.fetchSiteConfigurations = { site }

        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { _ in }
        viewModelEnv.proximityManager = .init(environment: proximityManagerEnv)

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = CallViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar

        var notificationCenter = FoundationBased.NotificationCenter.failing
        notificationCenter.removeObserverClosure = { _ in }
        notificationCenter.removeObserverWithNameAndObject = { _, _, _ in }
        notificationCenter.addObserverClosure = { _, _, _, _ in }

        let env = CallViewController.Environment(
            viewFactory: .mock(),
            notificationCenter: notificationCenter,
            log: .mock,
            timerProviding: .failing,
            gcd: .failing,
            alertManager: .mock()
        )
        let viewController = CallViewController(
            viewModel: viewModel,
            environment: env
        )

        viewController.loadView()
        interactor.state = .engaged(nil)

        // Will be removed when async state observing is implemented
        await waitUntil {
            calls.contains(.presentSnackBar)
        }

        XCTAssertTrue(calls.contains(.presentSnackBar))
    }

    func testLiveObservationIndicationIsDisabled() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { [] }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: false
        )
        viewModelEnv.fetchSiteConfigurations = { site }

        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { _ in }
        viewModelEnv.proximityManager = .init(environment: proximityManagerEnv)

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = CallViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }

        var notificationCenter = FoundationBased.NotificationCenter.failing
        notificationCenter.removeObserverClosure = { _ in }
        notificationCenter.removeObserverWithNameAndObject = { _, _, _ in }
        notificationCenter.addObserverClosure = { _, _, _, _ in }
        Glia.sharedInstance.liveObservation.pause()
        let env = CallViewController.Environment(
            viewFactory: .mock(),
            notificationCenter: notificationCenter,
            log: .mock,
            timerProviding: .failing,
            gcd: .failing,
            alertManager: .mock()
        )
        let viewController = CallViewController(
            viewModel: viewModel,
            environment: env
        )

        viewController.loadView()
        interactor.state = .engaged(nil)

        XCTAssertEqual(calls, [])
    }

    func testLiveObservationIsDisabled() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { [] }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: false,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true
        )
        viewModelEnv.fetchSiteConfigurations = { site }

        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { _ in }
        viewModelEnv.proximityManager = .init(environment: proximityManagerEnv)

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = CallViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }

        var notificationCenter = FoundationBased.NotificationCenter.failing
        notificationCenter.removeObserverClosure = { _ in }
        notificationCenter.removeObserverWithNameAndObject = { _, _, _ in }
        notificationCenter.addObserverClosure = { _, _, _, _ in }
        Glia.sharedInstance.liveObservation.pause()
        let env = CallViewController.Environment(
            viewFactory: .mock(),
            notificationCenter: notificationCenter,
            log: .mock,
            timerProviding: .failing,
            gcd: .failing,
            alertManager: .mock()
        )
        let viewController = CallViewController(
            viewModel: viewModel,
            environment: env
        )

        viewController.loadView()
        interactor.state = .engaged(nil)

        XCTAssertEqual(calls, [])
    }
}
