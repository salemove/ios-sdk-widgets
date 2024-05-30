@testable import GliaWidgets
import GliaCoreSDK
import XCTest

class ChatViewControllerTests: XCTestCase {
    // This test is not specific to `ChatViewController`, however it
    // shows specifics of `UIViewController` life cycle.
    // In particular: once UIViewController.view referred, view controller
    // will not get deallocated immediately, but with some delay due to being
    // held in `autoreleasepool`. In order to ensure that it really
    // gets deallocated, it has to be created within separate `autoreleasepool`.
    // Once `viewController` leaves `autoreleasepool` scope, it gets deallocated.
    func test_vc_deinit() {
        weak var weakViewController: UIViewController?
        autoreleasepool {
            let viewController: UIViewController? = UIViewController()
            _ = viewController?.view
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "UIViewController not deinitilized")
    }

    func test_chat_deinit() {
        weak var weakViewController: ChatViewController?
        autoreleasepool {
            let viewController: ChatViewController? = ChatViewController(
                viewModel: .chat(ChatViewModel.mock(environment: ChatViewModel.Environment.mock)),
                environment: .init(
                    timerProviding: .mock,
                    viewFactory: .mock(),
                    gcd: .mock,
                    snackBar: .mock,
                    notificationCenter: .mock
                )
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "ChatViewController not deinitilized")
    }

    func testAuthenticationErrorIsShownInDialog() throws {
        enum Call: Equatable {
            case presentCriticalErrorAlert
        }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { completion in
            completion(.success([]))
        }

        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true
        )
        viewModelEnv.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.prefixedClosure = { _ in return .mock }
        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            environment: viewModelEnv
        )

        viewModel.engagementAction = { action in
            switch action {
            case let .showCriticalErrorAlert(conf, accessibilityIdentifier, dismissed):
                calls.append(.presentCriticalErrorAlert)
            default:
                break
            }
        }

        let error: CoreSdkClient.SalemoveError = .init(
            reason: "Authentication issue",
            error: CoreSdkClient.Authentication.Error.expiredAccessToken
        )
        interactor.fail(error: error)

        XCTAssertEqual(calls, [.presentCriticalErrorAlert])
    }

    func testLiveObservationIndicatorIsPresented() throws {
        enum Call: Equatable {
            case presentSnackBar, prefixedLog(String)
        }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { completion in
            completion(.success([]))
        }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true
        )
        viewModelEnv.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.prefixedClosure = {
            calls.append(.prefixedLog($0))
            return .mock
        }
        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        let env = ChatViewController.Environment(
            timerProviding: .failing,
            viewFactory: .mock(),
            gcd: .failing,
            snackBar: snackBar,
            notificationCenter: .failing
        )
        let viewController = ChatViewController(
            viewModel: .chat(viewModel),
            environment: env
        )
        viewController.loadView()
        interactor.state = .engaged(nil)
        XCTAssertEqual(
            calls, [
                .prefixedLog("ChatViewModel"),
                .presentSnackBar,
                .prefixedLog("ChatViewModel")
            ]
        )
    }

    func testLiveObservationIndicationIsDisabled() throws {
        enum Call: Equatable {
            case presentSnackBar, prefixedLog(String)
        }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { completion in
            completion(.success([]))
        }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: false
        )
        viewModelEnv.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.prefixedClosure = {
            calls.append(.prefixedLog($0))
            return .mock
        }
        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        let env = ChatViewController.Environment(
            timerProviding: .failing,
            viewFactory: .mock(),
            gcd: .failing,
            snackBar: snackBar,
            notificationCenter: .failing
        )
        let viewController = ChatViewController(
            viewModel: .chat(viewModel),
            environment: env
        )
        viewController.loadView()
        interactor.state = .engaged(nil)
        XCTAssertFalse(calls.contains(.presentSnackBar))
    }

    func testLiveObservationIsDisabled() throws {
        enum Call: Equatable {
            case presentSnackBar, prefixedLog(String)
        }
        var calls: [Call] = []

        var viewModelEnv = ChatViewModel.Environment.failing { completion in
            completion(.success([]))
        }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: false,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true
        )
        viewModelEnv.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.prefixedClosure = {
            calls.append(.prefixedLog($0))
            return .mock
        }
        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.async = { $0() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        let env = ChatViewController.Environment(
            timerProviding: .failing,
            viewFactory: .mock(),
            gcd: .failing,
            snackBar: snackBar,
            notificationCenter: .failing
        )
        let viewController = ChatViewController(
            viewModel: .chat(viewModel),
            environment: env
        )
        viewController.loadView()
        interactor.state = .engaged(nil)
        print(calls)
        XCTAssertFalse(calls.contains(.presentSnackBar))
    }
}
