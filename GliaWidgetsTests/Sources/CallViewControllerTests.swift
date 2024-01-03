@testable import GliaWidgets
import GliaCoreSDK
import XCTest

class CallViewControllerTests: XCTestCase {
    func test_call_deinit() {
        weak var weakViewController: CallViewController?
        autoreleasepool {
            let viewController: CallViewController? = CallViewController(
                viewModel: CallViewModel.mock(environment: CallViewModel.Environment.mock),
                environment: .init(
                    viewFactory: .mock(),
                    notificationCenter: .mock,
                    log: .mock,
                    timerProviding: .mock,
                    gcd: .mock,
                    snackBar: .mock
                )
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "CallViewController not deinitilized")
    }

    func testLiveObservationIndicatorIsPresented() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { completion in
            completion(.success([]))
        }
        let site = try CoreSdkClient.Site.mock(
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true
        )
        viewModelEnv.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }

        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { _ in }
        viewModelEnv.proximityManager = .init(environment: proximityManagerEnv)

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = CallViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }

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
            snackBar: snackBar
        )
        let viewController = CallViewController(
            viewModel: viewModel,
            environment: env
        )

        viewController.loadView()
        interactor.state = .engaged(nil)

        XCTAssertEqual(calls, [.presentSnackBar])
    }
}
