@testable import GliaWidgets
import XCTest

extension SecureConversationsTranscriptModelTests {
    func test_singleChoiceResponseCardActionIsNotSupported() async throws {
        let viewModel = createViewModel()
        viewModel.delegate = { _ in
            XCTFail("Single choice response card actions should not be handled")
        }

        let option = try ChatChoiceCardOption.mock()

        await viewModel.asyncEvent(.choiceOptionSelected(option, "messageId"))
    }

    func test_customResponseCardActionIsNotSupported() async throws {
        let viewModel = createViewModel()
        viewModel.delegate = { _ in
            XCTFail("Custom response card actions should not be handled")
        }

        let option = HtmlMetadata.Option(text: "text", value: "value")
        let messageId = MessageRenderer.Message.Identifier(rawValue: "messageId")
        await viewModel.asyncEvent(
            .customCardOptionSelected(
                option: option,
                messageId: messageId
            )
        )
    }
}

private extension SecureConversationsTranscriptModelTests {
    func createViewModel() -> TranscriptModel {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { callback in callback(.success([])) }
        modelEnv.uiApplication.canOpenURL = { _ in true }
        modelEnv.maximumUploads = { 2 }
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
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
    }
}
