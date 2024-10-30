@testable import GliaWidgets
import XCTest

extension SecureConversationsTranscriptModelTests {
    func test_singleChoiceResponseCardActionIsNotSupported() throws {
        let viewModel = createViewModel()
        viewModel.delegate = { _ in
            XCTFail("Single choice response card actions should not be handled")
        }

        let option = try ChatChoiceCardOption.mock()

        viewModel.event(.choiceOptionSelected(option, "messageId"))
    }

    func test_customResponseCardActionIsNotSupported() throws {
        let viewModel = createViewModel()
        viewModel.delegate = { _ in
            XCTFail("Custom response card actions should not be handled")
        }

        let option = HtmlMetadata.Option(text: "text", value: "value")
        let messageId = MessageRenderer.Message.Identifier(rawValue: "messageId")
        viewModel.event(
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
        modelEnv.listQueues = { callback in callback([], nil) }
        modelEnv.uiApplication.canOpenURL = { _ in true }
        modelEnv.maximumUploads = { 2 }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock()
        )

        return TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: .failing
        )
    }
}
