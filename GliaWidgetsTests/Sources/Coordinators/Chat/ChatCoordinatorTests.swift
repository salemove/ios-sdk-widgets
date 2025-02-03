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
        environment: ChatCoordinator.Environment = .mock,
        startWithSecureTranscriptFlow: Bool = false,
        skipTransferredSCHandling: Bool = false
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
            environment: environment,
            startWithSecureTranscriptFlow: startWithSecureTranscriptFlow,
            skipTransferredSCHandling: skipTransferredSCHandling
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
        case .transcript:
            XCTAssertTrue(true)
        default: 
            XCTFail()
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
            viewModel.engagementAction?(.showAlert(.unavailableMessageCenter()))

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
            isTransferredToSecureConversations: false,
            startWithSecureTranscriptFlow: true,
            isAuthenticated: false
        )

        XCTAssertEqual(chatType, .secureTranscript(upgradedFromChat: false))
    }

    func test_chatTypeIsSecureTranscriptUpgradedFromChat() {
        let chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: true,
            startWithSecureTranscriptFlow: false,
            isAuthenticated: false
        )

        XCTAssertEqual(chatType, .secureTranscript(upgradedFromChat: true))
    }

    func test_chatTypeIsAuthenticated() {
        let chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: false,
            startWithSecureTranscriptFlow: false,
            isAuthenticated: true
        )

        XCTAssertEqual(chatType, .authenticated)
    }

    func test_chatTypeIsNonAuthenticated() {
        let chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: false,
            startWithSecureTranscriptFlow: false,
            isAuthenticated: false
        )

        XCTAssertEqual(chatType, .nonAuthenticated)
    }

    func test_delegateEventUpgradesChatToSC() {
        let coordinator = createCoordinator(startWithSecureTranscriptFlow: false)
        let controller = coordinator.start()
        let chatModel: ChatViewModel
        switch controller.viewModel {
        case let .chat(model):
            chatModel = model
        case let .transcript(model):
            XCTFail("Unexpected model of type \(type(of: model))")
            return
        }

        // Place some messages into chat model to
        // make sure that all section are migrated from chat
        // to transcript model.
        let visitorMessage = ChatItem(kind: .mock(kind: .visitorMessage))
        chatModel.pendingSection.append(visitorMessage)

        let operatorMessage = ChatItem(kind: .mock(kind: .operatorMessage))
        chatModel.messagesSection.append(operatorMessage)
        let choiceCard = ChatItem(kind: .mock(kind: .choiceCard))
        chatModel.messagesSection.append(choiceCard)
        let customCard = ChatItem(kind: .mock(kind: .customCard))
        chatModel.messagesSection.append(customCard)
        let gvaGallery = ChatItem(kind: .mock(kind: .gvaGallery))
        chatModel.messagesSection.append(gvaGallery)
        let gvaPersistentButton = ChatItem(kind: .mock(kind: .gvaPersistentButton))
        chatModel.messagesSection.append(gvaPersistentButton)
        let gvaQuickReply = ChatItem(kind: .mock(kind: .gvaQuickReply))
        chatModel.messagesSection.append(gvaQuickReply)
        let gvaResponseText = ChatItem(kind: .mock(kind: .gvaResponseText))
        chatModel.messagesSection.append(gvaResponseText)
        let outgoingMessage = ChatItem(kind: .mock(kind: .outgoingMessage))
        chatModel.messagesSection.append(outgoingMessage)
        let systemMessage = ChatItem(kind: .mock(kind: .systemMessage))
        chatModel.messagesSection.append(systemMessage)

        // Append items that will not be migrated
        chatModel.queueOperatorSection.append(.init(kind: .mock(kind: .operatorConnected)))
        chatModel.messagesSection.append(.init(kind: .mock(kind: .callUpgrade)))
        chatModel.messagesSection.append(.init(kind: .mock(kind: .queueOperator)))
        chatModel.messagesSection.append(.init(kind: .mock(kind: .transferring)))
        chatModel.messagesSection.append(.init(kind: .mock(kind: .unreadMessageDivider)))

        chatModel.delegate?(.liveChatEngagementUpgradedToSecureMessaging(chatModel))

        let transcriptModel: SecureConversations.TranscriptModel

        switch controller.viewModel {
        case let .transcript(model):
            transcriptModel = model
        case let .chat(model):
            XCTFail("Unexpected model of type \(type(of: model)). Expected \(SecureConversations.TranscriptModel.self)")
            return
        }

        // Since `Section` does not conform to `Equatable`,
        // some extra checks are required to make sure
        // that migration happens as expected.
        XCTAssertFalse(chatModel.sections.isEmpty)

        let expectedSectionItems = [
            visitorMessage,
            operatorMessage,
            choiceCard,
            customCard,
            gvaGallery,
            gvaPersistentButton,
            gvaQuickReply,
            gvaResponseText,
            outgoingMessage,
            systemMessage
        ]

        // Check whether sections except historySection are empty.
        for section in transcriptModel.sections where section !== transcriptModel.historySection {
            XCTAssertTrue(section.items.isEmpty)
        }

        // Check whether historySection contains only items reflected in chat transcript.
        for idx in transcriptModel.historySection.items.indices {
            XCTAssertTrue(transcriptModel.historySection.items[idx] === expectedSectionItems[idx])
        }

        XCTAssertEqual(chatModel.isViewLoaded, transcriptModel.isViewLoaded)
    }

    func test_chatTypeWhenSkipTransferredSCHandlingIsFalseAndTransferredScExists() {
        var environment = ChatCoordinator.Environment.mock
        environment.getCurrentEngagement = {
            .mock(status: .transferring, capabilities: .init(text: true))
        }
        environment.isAuthenticated = { true }
        let coordinator = createCoordinator(
            environment: environment,
            skipTransferredSCHandling: false
        )
        let controller = coordinator.start()
        let chatModel: ChatViewModel
        switch controller.viewModel {
        case let .chat(model):
            chatModel = model
        case let .transcript(model):
            XCTFail("Unexpected model of type \(type(of: model))")
            return
        }

        XCTAssertEqual(chatModel.chatType, .secureTranscript(upgradedFromChat: true))
    }

    func test_chatTypeWhenSkipTransferredSCHandlingIsTrueAndTransferredScExists() {
        var environment = ChatCoordinator.Environment.mock
        environment.getCurrentEngagement = {
            .mock(status: .transferring, capabilities: .init(text: true))
        }
        environment.isAuthenticated = { true }
        let coordinator = createCoordinator(
            environment: environment,
            skipTransferredSCHandling: true
        )
        let controller = coordinator.start()
        let chatModel: ChatViewModel
        switch controller.viewModel {
        case let .chat(model):
            chatModel = model
        case let .transcript(model):
            XCTFail("Unexpected model of type \(type(of: model))")
            return
        }

        XCTAssertEqual(chatModel.chatType, .authenticated)
    }

    func test_chatTypeWhenSkipTransferredSCHandlingIsFalseAndNoOngoingEngagement() {
        var environment = ChatCoordinator.Environment.mock
        environment.getCurrentEngagement = { nil }
        environment.isAuthenticated = { true }
        let coordinator = createCoordinator(
            environment: environment,
            skipTransferredSCHandling: true
        )
        let controller = coordinator.start()
        let chatModel: ChatViewModel
        switch controller.viewModel {
        case let .chat(model):
            chatModel = model
        case let .transcript(model):
            XCTFail("Unexpected model of type \(type(of: model))")
            return
        }

        XCTAssertEqual(chatModel.chatType, .authenticated)
    }
}
