import Foundation
import XCTest
@testable import GliaWidgets

final class SecureConversationsCoordinatorTests: XCTestCase {
    var navigationPresenter = NavigationPresenter(with: NavigationController())
    var coordinator: SecureConversations.Coordinator!

    override func setUp() {
        coordinator = createCoordinator()
    }

    func createCoordinator(
        initialScreen: SecureConversations.InitialScreen = .welcome
    ) -> SecureConversations.Coordinator {
        return SecureConversations.Coordinator(
            messagingInitialScreen: initialScreen,
            viewFactory: .mock(),
            navigationPresenter: navigationPresenter,
            environment: .mock
        )
    }

    // Start
    func test_startGeneratesWelcomeViewController() {
        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController

        XCTAssertNotNil(viewController)
    }

    func test_startGeneratesChatViewController() {
        let coordinator = createCoordinator(initialScreen: .chatTranscript)
        let viewController = coordinator.start() as? ChatViewController

        XCTAssertNotNil(viewController)
    }

    // Delegate
    func test_backTapped() {
        coordinator.delegate = { event in
            switch event {
            case .backTapped: XCTAssertTrue(true)
            default: XCTFail()
            }
        }

        coordinator.viewModel?.delegate?(.backTapped)
    }

    func test_closeTapped() {
        coordinator.delegate = { event in
            switch event {
            case .closeTapped(let presentation):
                XCTAssertEqual(presentation, .doNotPresentSurvey)
            default: XCTFail()
            }
        }

        coordinator.viewModel?.delegate?(.backTapped)
    }

    func test_renderProps() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)
        coordinator.viewModel?.delegate?(.renderProps(.mock))

        XCTAssertEqual(.mock, welcomeViewController.props)
    }

    func test_confirmationScreenRequested() {
        _ = coordinator.start()
        coordinator.viewModel?.delegate?(.confirmationScreenRequested)
        let confirmationViewController = navigationPresenter.viewControllers
            .last as? SecureConversations.ConfirmationViewController

        XCTAssertNotNil(confirmationViewController)
    }

    func test_mediaPickerRequested() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = welcomeViewController
        defer { window?.rootViewController = oldRootViewController }
        coordinator.viewModel?.delegate?(
            .mediaPickerRequested(
                from: welcomeViewController.view,
                callback: { _ in }
            )
        )
        let presentedViewController = welcomeViewController.presentedViewController as? PopoverViewController

        XCTAssertNotNil(presentedViewController)
    }

    // Take media is not tested because this triggers the native
    // "App would like to access the camera" dialog, which could
    // bring unintended consequences.
    func test_pickMedia() {
        _ = coordinator.start()

        XCTAssertNil(coordinator.selectedPickerController)

        coordinator.viewModel?.delegate?(.pickMedia(.nop))
        XCTAssertNotNil(coordinator.selectedPickerController)
        
        switch coordinator.selectedPickerController {
        case .mediaPickerController(let controller):
            XCTAssertEqual(controller.viewModel.source, .library)
        default: XCTFail()
        }
    }

    func test_pickFile() {
        _ = coordinator.start()

        XCTAssertNil(coordinator.selectedPickerController)

        coordinator.viewModel?.delegate?(.pickFile(.nop))
        XCTAssertNotNil(coordinator.selectedPickerController)

        switch coordinator.selectedPickerController {
        case .filePickerController: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    func test_showAlert() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = welcomeViewController
        defer { window?.rootViewController = oldRootViewController }

        let configuration = MessageAlertConfiguration(
            title: "",
            message: ""
        )
        coordinator.viewModel?.delegate?(
            .showAlert(
                configuration,
                accessibilityIdentifier: nil,
                dismissed: nil
            )
        )

        let presentedViewController = welcomeViewController.presentedViewController as? AlertViewController

        XCTAssertNotNil(presentedViewController)
    }

    func test_showAlertAsView() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = welcomeViewController
        defer { window?.rootViewController = oldRootViewController }

        let configuration = MessageAlertConfiguration(
            title: "",
            message: ""
        )
        coordinator.viewModel?.delegate?(
            .showAlertAsView(
                configuration,
                accessibilityIdentifier: nil,
                dismissed: nil
            )
        )

        let presentedViewController = welcomeViewController.children.first { $0 is AlertViewController }

        XCTAssertNotNil(presentedViewController)
    }

    func test_showSettingsAlert() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = welcomeViewController
        defer { window?.rootViewController = oldRootViewController }

        let configuration = SettingsAlertConfiguration(
            title: "",
            message: "",
            settingsTitle: "", 
            cancelTitle: ""
        )
        coordinator.viewModel?.delegate?(
            .showSettingsAlert(
                configuration,
                cancelled: { }
            )
        )

        let presentedViewController = welcomeViewController.presentedViewController as? UIAlertController

        XCTAssertNotNil(presentedViewController)
    }

    func test_transcriptRequested() {
        _ = coordinator.start()
        coordinator.viewModel?.delegate?(.transcriptRequested)
        let transcriptViewController = navigationPresenter.viewControllers
            .last as? ChatViewController

        XCTAssertNotNil(transcriptViewController)
    }
}
