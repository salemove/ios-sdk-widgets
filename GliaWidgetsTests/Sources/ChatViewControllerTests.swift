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
                    snackBar: .mock
                )
            )
            weakViewController = viewController
        }
        XCTAssertNil(weakViewController, "ChatViewController not deinitilized")
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
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.asyncIfNeeded = { $0() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        var snackBar = SnackBar.failing
        snackBar.present = { _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        let env = ChatViewController.Environment(
            timerProviding: .failing,
            viewFactory: .mock(),
            gcd: .failing,
            snackBar: snackBar
        )
        let viewController = ChatViewController(
            viewModel: .chat(viewModel),
            environment: env
        )
        viewController.loadView()
        interactor.state = .engaged(nil)

        XCTAssertEqual(calls, [.presentSnackBar])
    }
}
