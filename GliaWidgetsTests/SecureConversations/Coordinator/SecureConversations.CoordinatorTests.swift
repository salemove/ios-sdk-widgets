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
        initialScreen: SecureConversations.InitialScreen = .welcome,
        environment: SecureConversations.Coordinator.Environment = .mock
    ) -> SecureConversations.Coordinator {
        return SecureConversations.Coordinator(
            messagingInitialScreen: initialScreen,
            viewFactory: .mock(),
            navigationPresenter: navigationPresenter,
            environment: environment
        )
    }

    // Start
    func test_startGeneratesWelcomeViewController() {
        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController
        
        XCTAssertNotNil(viewController)
    }

    func test_socketObservation() {
        // Given
        enum Call {
            case startSocketObservation
            case stopSocketObservation
        }
        var calls: [Call] = []
        var environment = SecureConversations.Coordinator.Environment.mock
        environment.startSocketObservation = { calls.append(.stopSocketObservation) }
        environment.stopSocketObservation = { calls.append(.stopSocketObservation) }
        var coordinator: SecureConversations.Coordinator? = createCoordinator(
            initialScreen: .chatTranscript,
                environment: environment)

        // When
        _ = coordinator?.start()
        coordinator = nil

        // Then
        XCTAssertEqual(calls.count, 2)
        XCTAssertEqual(calls, [.stopSocketObservation, .stopSocketObservation])
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

        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController
        viewController?.viewModel.delegate?(.backTapped)
    }

    func test_closeTapped() {
        coordinator.delegate = { event in
            switch event {
            case .closeTapped(let presentation):
                XCTAssertEqual(presentation, .doNotPresentSurvey)
            default: XCTFail()
            }
        }

        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController
        viewController?.viewModel.delegate?(.closeTapped)
    }

    func test_renderProps() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)

        welcomeViewController.viewModel.delegate?(.renderProps(.mock))

        XCTAssertEqual(.mock, welcomeViewController.props)
    }

    func test_confirmationScreenRequested() {
        _ = coordinator.start()
        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController
        viewController?.viewModel.delegate?(.confirmationScreenRequested)
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
        welcomeViewController.viewModel.delegate?(
            .mediaPickerRequested(
                from: welcomeViewController.view,
                options: [.photoLibrary],
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
        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController

        XCTAssertNil(coordinator.selectedPickerController)

        viewController?.viewModel.delegate?(.pickMedia(.nop, [.image]))
        XCTAssertNotNil(coordinator.selectedPickerController)
        
        switch coordinator.selectedPickerController {
        case .mediaPickerController(let controller):
            XCTAssertEqual(controller.viewModel.source, .library)
        default: XCTFail()
        }
    }

    func test_pickFile() {
        let viewController = coordinator.start() as? SecureConversations.WelcomeViewController

        XCTAssertNil(coordinator.selectedPickerController)

        viewController?.viewModel.delegate?(.pickFile(.nop, .default))
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

        welcomeViewController.viewModel.delegate?(.showAlert(.mediaSourceNotAvailable()))

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

        welcomeViewController.viewModel.delegate?(.showAlert(.unavailableMessageCenter()))

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

        welcomeViewController.viewModel.delegate?(.showAlert(.cameraSettings()))

        let presentedViewController = welcomeViewController.presentedViewController as? UIAlertController

        XCTAssertNotNil(presentedViewController)
    }

    func test_transcriptRequested() throws {
        let welcomeViewController = try XCTUnwrap(coordinator.start() as? SecureConversations.WelcomeViewController)
        welcomeViewController.viewModel.delegate?(.transcriptRequested)
        let transcriptViewController = navigationPresenter.viewControllers
            .last as? ChatViewController

        XCTAssertNotNil(transcriptViewController)
    }
}
