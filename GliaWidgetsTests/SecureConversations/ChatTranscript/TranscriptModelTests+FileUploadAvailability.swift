@_spi(GliaWidgets) internal import GliaCoreSDK
@testable import GliaWidgets
import XCTest

// Attachment button enabling by secure file upload availability.
extension SecureConversationsTranscriptModelTests {
    @MainActor
    func testMediaPickerButtonEnablingDependsOnSiteConfiguration() async throws {
        let viewModel = try makeModelWithAttachmentsAllowed(
            fileUploadAvailabilityStream: { AsyncThrowingStream { $0.yield(true) } }
        )
        let enabled = expectAttachmentButtonEnabling(of: viewModel, isEnabled: true)

        await viewModel.start(isTranscriptFetchNeeded: true)
        await fulfillment(of: [enabled], timeout: 1)

        XCTAssertFalse(viewModel.mediaPickerButtonEnabling.isDisabled)
    }

    @MainActor
    func testMediaPickerButtonIsDisabledUntilSecureFileUploadIsAvailable() async throws {
        var availability: AsyncThrowingStream<Bool, Error>.Continuation?
        let stream = AsyncThrowingStream<Bool, Error> { availability = $0 }
        let viewModel = try makeModelWithAttachmentsAllowed(fileUploadAvailabilityStream: { stream })

        await viewModel.start(isTranscriptFetchNeeded: true)
        availability?.yield(false)
        XCTAssertTrue(viewModel.mediaPickerButtonEnabling.isDisabled)

        let enabled = expectAttachmentButtonEnabling(of: viewModel, isEnabled: true)
        availability?.yield(true)
        await fulfillment(of: [enabled], timeout: 1)

        guard case .enabled(.secureMessaging) = viewModel.mediaPickerButtonEnabling else {
            return XCTFail("Expected the attachment button to be enabled for secure messaging")
        }
    }

    @MainActor
    func testMediaPickerButtonIsDisabledAgainWhenSecureFileUploadBecomesUnavailable() async throws {
        var availability: AsyncThrowingStream<Bool, Error>.Continuation?
        let stream = AsyncThrowingStream<Bool, Error> { availability = $0 }
        let viewModel = try makeModelWithAttachmentsAllowed(fileUploadAvailabilityStream: { stream })
        await viewModel.start(isTranscriptFetchNeeded: true)

        let enabled = expectAttachmentButtonEnabling(of: viewModel, isEnabled: true)
        availability?.yield(true)
        await fulfillment(of: [enabled], timeout: 1)

        let disabled = expectAttachmentButtonEnabling(of: viewModel, isEnabled: false)
        availability?.yield(false)
        await fulfillment(of: [disabled], timeout: 1)

        XCTAssertTrue(viewModel.mediaPickerButtonEnabling.isDisabled)
    }

    @MainActor
    func testMediaPickerButtonStaysDisabledWhenFileUploadAvailabilityCannotBeObserved() async throws {
        let viewModel = try makeModelWithAttachmentsAllowed(
            fileUploadAvailabilityStream: { throw CoreSdkClient.GliaCoreError(reason: "") }
        )

        await viewModel.start(isTranscriptFetchNeeded: true)

        XCTAssertTrue(viewModel.mediaPickerButtonEnabling.isDisabled)
    }

    /// A model whose site allows visitor attachments, so the attachment button depends only on
    /// secure file upload availability.
    private func makeModelWithAttachmentsAllowed(
        fileUploadAvailabilityStream: @escaping CoreSdkClient.SecureConversations.FileUploadAvailabilityStream
    ) throws -> TranscriptModel {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = FileUploadListViewModel.mock(environment:)
        modelEnv.uiApplication.preferredContentSizeCategory = { .unspecified }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { .init(messages: []) }
        modelEnv.secureConversations.getUnreadMessageCount = { 0 }
        modelEnv.secureConversations.fileUploadAvailabilityStream = fileUploadAvailabilityStream
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        let site = try CoreSdkClient.Site.mock(
            allowedFileContentTypes: ["image/jpeg"],
            allowedFileSenders: .mock(visitor: true)
        )
        modelEnv.fetchSiteConfigurations = { site }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        return TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
    }

    /// Fulfilled once the model tells the view to set the attachment button to the given enabling.
    private func expectAttachmentButtonEnabling(of viewModel: TranscriptModel, isEnabled: Bool) -> XCTestExpectation {
        let reported = expectation(description: "Attachment button enabled: \(isEnabled)")
        reported.assertForOverFulfill = false
        viewModel.action = { action in
            guard case let .setAttachmentButtonEnabling(enabling) = action, enabling.isDisabled != isEnabled else { return }
            reported.fulfill()
        }
        return reported
    }
}
