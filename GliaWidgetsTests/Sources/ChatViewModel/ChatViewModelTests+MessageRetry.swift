@testable import GliaWidgets
import XCTest
import GliaCoreSDK

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

    func testSendMessageRetryUpdatesCustomCard() {
        let selectedOption = "selected_option"
        let customCardMessageId = UUID.mock.uuidString
        let outgoingMessage = OutgoingMessage.mock(
            relation: .customCard(messageId: .init(rawValue: customCardMessageId))
        )
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

            case let .setChoiceCardInputModeEnabled(enabled):
                calls.append(.setChoiceCardInputModeEnabled(enabled))

            default:
                XCTFail("unexpected action was called")
            }
        }

        let expectedCalls: [Call] = [
            .deleteRows([1], 3, true),
            .appendRows(1, 3, true),
            .scrollToBottom(true),
            .refreshRows([2], 3, false),
            .scrollToBottom(true),
            .setChoiceCardInputModeEnabled(false)
        ]

        /*
         1st - custom card message
         2nd - failed outgoing custom card response
         3rd - successfully sent visitor message
         */
        viewModel.messagesSection.append(
            .init(
                kind: .customCard(
                    .mock(
                        id: customCardMessageId,
                        attachment: .mock(
                            type: nil,
                            files: nil,
                            imageUrl: nil,
                            options: nil
                        )
                    ),
                    showsImage: false,
                    imageUrl: nil,
                    isActive: true
                )
            )
        )
        viewModel.messagesSection.append(.init(kind: .outgoingMessage(outgoingMessage, error: "Failed")))
        viewModel.messagesSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))
        outgoingMessage.payload.attachment = .init(
            type: nil,
            selectedOption: selectedOption,
            options: nil,
            files: nil,
            imageUrl: nil
        )
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

        // Check if custom card message was updated with selected option
        switch viewModel.messagesSection.items.first?.kind {
        case let .customCard(message, _, _, _):
            XCTAssertEqual(message.attachment?.selectedOption, selectedOption)
        default:
            XCTFail("message kind should be `operatorMessage`")
        }
    }

    func testSendMessageRetryUpdatesResponseCard() {
        let selectedOption = "selected_option"
        let responseCardMessageId = UUID.mock.uuidString
        let outgoingMessage = OutgoingMessage.mock(
            relation: .singleChoice(messageId: .init(rawValue: responseCardMessageId))
        )
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

            case let .setChoiceCardInputModeEnabled(enabled):
                calls.append(.setChoiceCardInputModeEnabled(enabled))

            case let .refreshRow(row, section, animated):
                calls.append(.refreshRow(row, section, animated))

            case .refreshAll:
                calls.append(.refreshAll)

            default:
                XCTFail("unexpected action was called")
            }
        }

        let expectedCalls: [Call] = [
            .deleteRows([1], 3, true),
            .appendRows(1, 3, true),
            .scrollToBottom(true),
            .refreshRows([2], 3, false),
            .scrollToBottom(true),
            .refreshRow(0, 3, true),
            .setChoiceCardInputModeEnabled(false),
            .refreshAll
        ]

        /*
         1st - response card message
         2nd - failed response card response
         3rd - successfully sent visitor message
         */
        viewModel.messagesSection.append(
            .init(
                kind: .choiceCard(
                    .mock(
                        id: responseCardMessageId,
                        attachment: .mock(
                            type: nil,
                            files: nil,
                            imageUrl: nil,
                            options: nil
                        )
                    ),
                    showsImage: false,
                    imageUrl: nil,
                    isActive: true
                )
            )
        )
        viewModel.messagesSection.append(.init(kind: .outgoingMessage(outgoingMessage, error: "Failed")))
        viewModel.messagesSection.append(.init(kind: .visitorMessage(ChatMessage.mock(), status: nil)))
        outgoingMessage.payload.attachment = .init(
            type: nil,
            selectedOption: selectedOption,
            options: nil,
            files: nil,
            imageUrl: nil
        )
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

        // Check if custom card message was replaced with operator message
        switch viewModel.messagesSection.items.first?.kind {
        case let .operatorMessage(message, _, _):
            XCTAssertEqual(message.attachment?.selectedOption, selectedOption)
        default:
            XCTFail("message kind should be `operatorMessage`")
        }
    }
}

private extension ChatViewModelTests {
    enum Call: Equatable {
        case deleteRows([Int], Int, Bool)
        case appendRows(Int, Int, Bool)
        case refreshRow(Int, Int, Bool)
        case refreshRows([Int], Int, Bool)
        case scrollToBottom(Bool)
        case setChoiceCardInputModeEnabled(Bool)
        case refreshAll
    }
}
