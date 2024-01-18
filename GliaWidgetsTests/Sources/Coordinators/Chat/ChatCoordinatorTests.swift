import Foundation
import XCTest
import QuickLook
@testable import GliaWidgets

final class ChatCoordinatorTests: XCTestCase {
    var coordinator: ChatCoordinator!
    var navigationPresenter = NavigationPresenter(with: NavigationController())

    override func setUp() {
        coordinator = createCoordinator()
    }

    func createCoordinator(
        startWithSecureTranscriptFlow: Bool = false
    ) -> ChatCoordinator {
        return ChatCoordinator(
            interactor: .mock(),
            viewFactory: .mock(),
            navigationPresenter: navigationPresenter,
            call: .init(with: .mock()),
            unreadMessages: .init(with: 0),
            showsCallBubble: false,
            screenShareHandler: .mock,
            isWindowVisible: .init(with: true),
            startAction: .startEngagement,
            environment: .mock,
            startWithSecureTranscriptFlow: startWithSecureTranscriptFlow
        )
    }

    func test_startGeneratesChatViewController() {
        let viewController = coordinator.start()

        XCTAssertNotNil(viewController)
    }

    // View model

    func test_correctViewModelForChat() {
        let viewController = coordinator.start()

        switch viewController.viewModel {
        case .chat: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    func test_correctViewModelForSecureTranscript() {
        let viewController = createCoordinator(startWithSecureTranscriptFlow: true)
            .start()

        switch viewController.viewModel {
        case .transcript: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    // Delegate for chat model

    // Take media is not tested because this triggers the native
    // "App would like to access the camera" dialog, which could
    // bring unintended consequences.
    func test_chatModelPickMedia() throws {
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .chat(let viewModel):
            viewModel.delegate?(.pickMedia(.init(with: .cancelled)))
            coordinator.mediaPickerController?.viewController{ shownViewController in
                XCTAssertNotNil(shownViewController as? UIImagePickerController)
            }
        default: XCTFail()
        }
    }

    func test_chatModelPickFile() throws {
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .chat(let viewModel):
            viewModel.delegate?(.pickFile(.init(with: .cancelled)))
            let filePickerController = coordinator.filePickerController?.viewController as? UIDocumentPickerViewController

            XCTAssertNotNil(filePickerController)
        default: XCTFail()
        }
    }

    func test_chatModelMediaUpgradeAccepted() throws {
        let viewController = coordinator.start()
        let mediaOffer: CoreSdkClient.MediaUpgradeOffer = try .init(
            type: .audio,
            direction: .twoWay
        )
        
        var calledEvents: [ChatCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        switch viewController.viewModel {
        case .chat(let viewModel):

            viewModel.delegate?(
                .mediaUpgradeAccepted(
                    offer: mediaOffer,
                    answer: { _, _ in}
                )
            )
        default: XCTFail()
        }

        XCTAssertEqual(calledEvents.count, 1)

        switch try XCTUnwrap(calledEvents.first) {
        case .mediaUpgradeAccepted(let offer, _): XCTAssertEqual(mediaOffer, offer)
        default: XCTFail()
        }
    }

    func test_chatModelSecureTranscriptUpgradedToLiveChat() throws {
        let viewController = coordinator.start()
        let mockedChatViewController: ChatViewController = .mock()

        var calledEvents: [ChatCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        switch viewController.viewModel {
        case .chat(let viewModel):
            viewModel.delegate?(.secureTranscriptUpgradedToLiveChat(mockedChatViewController))
        default: XCTFail()
        }

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .secureTranscriptUpgradedToLiveChat(let chatViewController):
            XCTAssertEqual(mockedChatViewController, chatViewController)
        default: XCTFail()
        }
    }

    func test_chatModelShowFile() throws {
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .chat(let viewModel):
            viewModel.delegate?(.showFile(.mock()))
            let quickLookController = coordinator.quickLookController?.viewController

            XCTAssertNotNil(quickLookController)
        default: XCTFail()
        }
    }

    func test_chatModelCall() throws {
        let viewController = coordinator.start()

        switch viewController.viewModel {
        case .chat(let viewModel): viewModel.delegate?(.call)
        default: XCTFail()
        }
    }

    // Engagement delegate for chat model

    func test_chatModelBack() throws {
        let viewController = coordinator.start()

        var calledEvents: [ChatCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        switch viewController.viewModel {
        case .chat(let viewModel): viewModel.engagementDelegate?(.back)
        default: XCTFail()
        }

        switch try XCTUnwrap(calledEvents.first) {
        case .back: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    func test_chatModelOpenLink() throws {
        let viewController = coordinator.start()

        var calledEvents: [ChatCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        switch viewController.viewModel {
        case .chat(let viewModel):
            let link = (title: "", url: URL.mock)

            viewModel.engagementDelegate?(.openLink(link))
        default: XCTFail()
        }

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .openLink(let link): XCTAssertEqual(link.url, URL.mock)
        default: XCTFail()
        }
    }

    func test_chatModelEngaged() throws {
        let viewController = coordinator.start()
        let urlString = URL.mock.absoluteString

        var calledEvents: [ChatCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        switch viewController.viewModel {
        case .chat(let viewModel):
            viewModel.engagementDelegate?(.engaged(operatorImageUrl: urlString))
        default: XCTFail()
        }

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .engaged(let operatorImageUrl): XCTAssertEqual(operatorImageUrl, urlString)
        default: XCTFail()
        }
    }

    func test_chatModelFinished() throws {
        let viewController = coordinator.start()

        var calledEvents: [ChatCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        switch viewController.viewModel {
        case .chat(let viewModel):
            viewModel.engagementDelegate?(.finished)
        default: XCTFail()
        }

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .finished: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    // Delegate for transcript model

    func test_transcriptModelShowFile() throws {
        let coordinator = createCoordinator(startWithSecureTranscriptFlow: true)
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .transcript(let viewModel):
            viewModel.delegate?(.showFile(.mock()))
            let quickLookController = coordinator.quickLookController?.viewController

            XCTAssertNotNil(quickLookController)
        default: XCTFail()
        }
    }

    func test_transcriptModelShowAlertAsView() throws {
        let coordinator = createCoordinator(startWithSecureTranscriptFlow: true)
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .transcript(let viewModel):
            let configuration = MessageAlertConfiguration(
                title: "",
                message: ""
            )

            viewModel.delegate?(
                .showAlertAsView(
                    configuration,
                    accessibilityIdentifier: nil,
                    dismissed: nil
                )
            )

            let presentedViewController = viewController.children.first { $0 is AlertViewController }

            XCTAssertNotNil(presentedViewController)

        default: XCTFail()
        }
    }

    // Take media is not tested because this triggers the native
    // "App would like to access the camera" dialog, which could
    // bring unintended consequences.
    func test_transcriptModelPickMedia() throws {
        let coordinator = createCoordinator(startWithSecureTranscriptFlow: true)
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .transcript(let viewModel):
            viewModel.delegate?(.pickMedia(.init(with: .cancelled)))
            coordinator.mediaPickerController?.viewController{ shownViewController in
                XCTAssertNotNil(shownViewController as? UIImagePickerController)
            }
        default: XCTFail()
        }
    }

    func test_transcriptModelPickFile() throws {
        let coordinator = createCoordinator(startWithSecureTranscriptFlow: true)
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .transcript(let viewModel):
            viewModel.delegate?(.pickFile(.init(with: .cancelled)))
            let filePickerController = coordinator.filePickerController?.viewController as? UIDocumentPickerViewController

            XCTAssertNotNil(filePickerController)
        default: XCTFail()
        }
    }

    func test_transcriptModelUpgradeToChatEngagement() throws {
        let coordinator = createCoordinator(startWithSecureTranscriptFlow: true)
        let viewController = coordinator.start()

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        switch viewController.viewModel {
        case .transcript(let viewModel):
            viewModel.delegate?(.upgradeToChatEngagement(viewModel))

            coordinator.delegate = { event in
                switch event {
                case .secureTranscriptUpgradedToLiveChat(let controller):
                    XCTAssertEqual(viewController, controller)
                default: XCTFail()
                }
            }

        default: XCTFail()
        }
    }

    // Chat type

    func test_chatTypeIsSecureTranscript() {
        let chatType = ChatCoordinator.chatType(
            startWithSecureTranscriptFlow: true,
            isAuthenticated: false
        )

        XCTAssertEqual(chatType, .secureTranscript)
    }

    func test_chatTypeIsAuthenticated() {
        let chatType = ChatCoordinator.chatType(
            startWithSecureTranscriptFlow: false,
            isAuthenticated: true
        )

        XCTAssertEqual(chatType, .authenticated)
    }

    func test_chatTypeIsNonAuthenticated() {
        let chatType = ChatCoordinator.chatType(
            startWithSecureTranscriptFlow: false,
            isAuthenticated: false
        )

        XCTAssertEqual(chatType, .nonAuthenticated)
    }
}
