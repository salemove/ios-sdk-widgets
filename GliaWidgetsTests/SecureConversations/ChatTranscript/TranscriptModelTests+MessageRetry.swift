@testable import GliaWidgets
import XCTest

extension SecureConversationsTranscriptModelTests {
    func testSendMessageRetrySuccess() {
        let outgoingMessage = OutgoingMessage.mock()
        var calls: [Call] = []
        let viewModel = createViewModel()

        viewModel.action = { action in
            switch action {
            case let .deleteRows(rows, section, animated):
                calls.append(.deleteRows(rows, section, animated))

            case let .appendRows(index, section, animated):
                calls.append(.appendRows(index, section, animated))

            case let .scrollToBottom(animated):
                calls.append(.scrollToBottom(animated))

            default:
                XCTFail("unexpected action was called")
            }
        }

        let expectedCalls: [Call] = [
            .deleteRows([1], 1, true),
            .appendRows(1, 1, true),
            .scrollToBottom(true)
        ]

        /*
         1st - successfully sent visitor message
         2nd - failed outgoing visitor message
         3rd - successfully sent visitor message
         */
        viewModel.pendingSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))
        viewModel.pendingSection.append(.init(kind: .outgoingMessage(outgoingMessage, error: "Failed")))
        viewModel.pendingSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))

        viewModel.event(.retryMessageTapped(outgoingMessage))

        XCTAssertEqual(calls, expectedCalls)
        XCTAssertEqual(viewModel.pendingSection.itemCount, 3)

        // Check if failed outgoing message was removed and added as last one
        switch viewModel.pendingSection.items.last?.kind {
        case let .outgoingMessage(message, error):
            XCTAssertEqual(message, outgoingMessage)
            XCTAssertNil(error)
        default:
            XCTFail("message kind should be `outgoingMessage`")
        }
    }

    func testSendMessageRetryFailure() {
        let outgoingMessage = OutgoingMessage.mock()
        var calls: [Call] = []
        let viewModel = createViewModel()

        viewModel.action = { action in
            switch action {
            case let .deleteRows(rows, section, animated):
                calls.append(.deleteRows(rows, section, animated))

            case let .appendRows(index, section, animated):
                calls.append(.appendRows(index, section, animated))

            case let .scrollToBottom(animated):
                calls.append(.scrollToBottom(animated))

            case let .refreshRows(rows, section, animated):
                calls.append(.refresh(rows, section, animated))

            default:
                XCTFail("unexpected action was called")
            }
        }

        viewModel.environment.sendSecureMessagePayload = { _, _, completion in
            completion(.failure(GliaError.internalError))
            return .mock
        }

        let expectedCalls: [Call] = [
            .deleteRows([1], 1, true),
            .appendRows(1, 1, true),
            .scrollToBottom(true),
            .refresh([2], 1, false)
        ]

        /*
         1st - successfully sent visitor message
         2nd - failed outgoing visitor message
         3rd - successfully sent visitor message
         */
        viewModel.pendingSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))
        viewModel.pendingSection.append(.init(kind: .outgoingMessage(outgoingMessage, error: "Failed")))
        viewModel.pendingSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))

        viewModel.event(.retryMessageTapped(outgoingMessage))

        XCTAssertEqual(calls, expectedCalls)
        XCTAssertEqual(viewModel.pendingSection.itemCount, 3)

        // Check if failed outgoing message was removed and added as last one
        switch viewModel.pendingSection.items.last?.kind {
        case let .outgoingMessage(message, error):
            XCTAssertEqual(message, outgoingMessage)
            XCTAssertEqual(error, "Failed")
        default:
            XCTFail("message kind should be `outgoingMessage`")
        }
    }
}

private extension SecureConversationsTranscriptModelTests {
    enum Call: Equatable {
        case deleteRows([Int], Int, Bool)
        case appendRows(Int, Int, Bool)
        case refresh([Int], Int, Bool)
        case scrollToBottom(Bool)
    }

    func createViewModel() -> TranscriptModel {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { callback in callback([], nil) }
        modelEnv.uiApplication.canOpenURL = { _ in true }
        modelEnv.maximumUploads = { 2 }
        modelEnv.sendSecureMessagePayload = { _, _, _ in .mock }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock(),
            getCurrentEngagement: { .mock() }
        )

        return TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "Failed",
            interactor: .failing
        )
    }
}
