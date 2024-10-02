@testable import GliaWidgets
import XCTest

extension ChatViewModelTests {
    func testSendMessageRetrySuccess() {
        let outgoingMessage = OutgoingMessage.mock()
        var calls: [Call] = []
        var interactorEnv = Interactor.Environment.mock
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _, completion in
            completion(.success(.mock(id: outgoingMessage.payload.messageId.rawValue)))
        }
        let interactorMock = Interactor.mock(environment: interactorEnv)
        let deliveredStatusText = "Delivered"
        viewModel = .mock(
            interactor: interactorMock,
            deliveredStatusText: deliveredStatusText
        )

        viewModel.action = { action in
            switch action {
            case let .deleteRows(rows, section, animated):
                calls.append(.deleteRows(rows, section, animated))

            case let .appendRows(index, section, animated):
                calls.append(.appendRows(index, section, animated))

            case let .scrollToBottom(animated):
                calls.append(.scrollToBottom(animated))

            case let .refreshRows(rows, section, animated):
                calls.append(.refreshRows(rows, section, animated))

            default:
                XCTFail("unexpected action was called")
            }
        }

        let expectedCalls: [Call] = [
            .deleteRows([1], 3, true),
            .appendRows(1, 3, true),
            .scrollToBottom(true),
            .refreshRows([2], 3, false),
            .scrollToBottom(true)
        ]

        /*
         1st - successfully sent visitor message
         2nd - failed outgoing visitor message
         3rd - successfully sent visitor message
         */
        viewModel.messagesSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))
        viewModel.messagesSection.append(.init(kind: .outgoingMessage(outgoingMessage, error: "Failed")))
        viewModel.messagesSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))

        viewModel.event(.retryMessageTapped(outgoingMessage))

        XCTAssertEqual(calls, expectedCalls)
        XCTAssertEqual(viewModel.messagesSection.itemCount, 3)

        // Check if failed outgoing message was removed and added as last one
        switch viewModel.messagesSection.items.last?.kind {
        case let .visitorMessage(message, status):
            XCTAssertEqual(message.id, outgoingMessage.payload.messageId.rawValue)
            XCTAssertEqual(status, deliveredStatusText)
        default:
            XCTFail("message kind should be `visitorMessage`")
        }
    }

    func testSendMessageRetryFailure() {
        let outgoingMessage = OutgoingMessage.mock()
        var calls: [Call] = []
        var interactorEnv = Interactor.Environment.mock
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _, completion in
            completion(.failure(.mock()))
        }
        let interactorMock = Interactor.mock(environment: interactorEnv)
        let failedToDeliverStatusText = "Failed"
        viewModel = .mock(
            interactor: interactorMock,
            failedToDeliverStatusText: failedToDeliverStatusText
        )

        viewModel.action = { action in
            switch action {
            case let .deleteRows(rows, section, animated):
                calls.append(.deleteRows(rows, section, animated))

            case let .appendRows(index, section, animated):
                calls.append(.appendRows(index, section, animated))

            case let .scrollToBottom(animated):
                calls.append(.scrollToBottom(animated))

            case let .refreshRows(rows, section, animated):
                calls.append(.refreshRows(rows, section, animated))

            default:
                XCTFail("unexpected action was called")
            }
        }

        let expectedCalls: [Call] = [
            .deleteRows([1], 3, true),
            .appendRows(1, 3, true),
            .scrollToBottom(true),
            .refreshRows([2], 3, false)
        ]

        /*
         1st - successfully sent visitor message
         2nd - failed outgoing visitor message
         3rd - successfully sent visitor message
         */
        viewModel.messagesSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))
        viewModel.messagesSection.append(.init(kind: .outgoingMessage(outgoingMessage, error: "Failed")))
        viewModel.messagesSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))

        viewModel.event(.retryMessageTapped(outgoingMessage))

        XCTAssertEqual(calls, expectedCalls)
        XCTAssertEqual(viewModel.messagesSection.itemCount, 3)

        // Check if failed outgoing message was removed and added as last one
        switch viewModel.messagesSection.items.last?.kind {
        case let .outgoingMessage(message, error):
            XCTAssertEqual(message, outgoingMessage)
            XCTAssertEqual(error, failedToDeliverStatusText)
        default:
            XCTFail("message kind should be `outgoingMessage`")
        }
    }
}

private extension ChatViewModelTests {
    enum Call: Equatable {
        case deleteRows([Int], Int, Bool)
        case appendRows(Int, Int, Bool)
        case refreshRows([Int], Int, Bool)
        case scrollToBottom(Bool)
    }
}
