@testable import GliaWidgets
import XCTest

extension SecureConversationsTranscriptModelTests {
    func test_gvaLinkButtonAction() {
        let options: [GvaOption] = [
            .mock(url: "http://mock.mock"),
            .mock(url: "https://mock.mock"),
            .mock(url: "mock://mock.self", urlTarget: "self"),
            .mock(url: "mock://mock.modal", urlTarget: "modal"),
            .mock(url: "mock://mock", urlTarget: "mock"),
            .mock(url: "mailto:mock@mock.mock"),
            .mock(url: "tel:12345678")
        ]
        var calls: [Call] = []

        let viewModel = createViewModel()
        viewModel.environment.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        viewModel.environment.sendSecureMessagePayload = { payload, _, _ in
            calls.append(.sendOption(payload.content, payload.attachment?.selectedOption))
            return .mock
        }
        options.forEach {
            viewModel.gvaOptionAction(for: $0)()
        }

        let expectedResult: [Call] = [
            .openUrl("http://mock.mock"),
            .openUrl("https://mock.mock"),
            .openUrl("mock://mock.self"),
            .openUrl("mock://mock.modal"),
            .openUrl("mailto:mock@mock.mock"),
            .openUrl("tel:12345678")
        ]
        XCTAssertEqual(calls, expectedResult)
    }

    func test_gvaPostbackButtonAction() {
        let option = GvaOption.mock(text: "text", value: "value")
        var calls: [Call] = []
        let viewModel = createViewModel()
        // To ensure `open` is not called in case of URL Button
        viewModel.environment.uiApplication.open = { url in
            calls.append(.openUrl(url.absoluteString))
        }
        viewModel.environment.sendSecureMessagePayload = { payload, _, _ in
            calls.append(.sendOption(payload.content, payload.attachment?.selectedOption))
            return .mock
        }
        viewModel.environment.createSendMessagePayload = {
            .mock(
                messageIdSuffix: "mockSuffix",
                content: $0,
                attachment: $1
            )
        }
        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.sendOption("text", "value")])
    }

    func test_broadcastEventAction() {
        let option = GvaOption.mock(text: "text", destinationPdBroadcastEvent: "mock")
        var calls: [Call] = []
        let viewModel = createViewModel()
        viewModel.engagementAction = { action in
            guard case .showAlert = action else { return }
            calls.append(.showAlert)
        }

        viewModel.gvaOptionAction(for: option)()

        XCTAssertEqual(calls, [.showAlert])
    }

    func test_quickReplyIsShownWhenItIsLastMessage() throws {
        enum Call { case quickReply }
        var calls: [Call] = []

        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback([], nil) }
        modelEnv.uiApplication.canOpenURL = { _ in true }
        modelEnv.maximumUploads = { 2 }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        modelEnv.log = logger

        let json = """
        { "id": "mock", "sender": 1, "content": "mock",
        "metadata": { "type": "quickReplies",
        "options": [{ "text": "mock" }], "content": "mock"
        }}
        """.utf8
        let message = try JSONDecoder().decode(
            ChatMessage.self,
            from: Data(json)
        )
        modelEnv.fetchChatHistory = { $0(.success([message])) }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { $0(.success(0)) }
        modelEnv.startSocketObservation = {}
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        viewModel.action = { action in
            guard case .quickReplyPropsUpdated = action else { return }
            calls.append(.quickReply)
        }
        viewModel.start()
        scheduler.run()

        XCTAssertEqual(calls, [.quickReply])
    }
}

private extension SecureConversationsTranscriptModelTests {
    enum Call: Equatable {
        case openUrl(String?)
        case sendOption(String?, String?)
        case showAlert
    }

    func createViewModel() -> TranscriptModel {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback([], nil) }
        modelEnv.uiApplication.canOpenURL = { _ in true }
        modelEnv.maximumUploads = { 2 }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        return TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
    }
}
