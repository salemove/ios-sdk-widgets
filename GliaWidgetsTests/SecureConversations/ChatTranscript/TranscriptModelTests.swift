@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest
import Combine

final class SecureConversationsTranscriptModelTests: XCTestCase {
    typealias TranscriptModel = SecureConversations.TranscriptModel
    typealias FileUploadListViewModel = SecureConversations.FileUploadListViewModel

    func testEmptyQueueSetsIsSecureConversationsAvailableToFalse() async {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
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
        await viewModel.checkSecureConversationsAvailability()

        XCTAssertFalse(viewModel.isSecureConversationsAvailable)
    }

    func testUnauthenticatedVisitorSetsIsSecureConversationsAvailableToFalse() async throws {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        let mockError = NSError(domain: "", code: 1)
        modelEnv.getQueues = { throw mockError }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { false },
            log: logger,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
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
        await viewModel.checkSecureConversationsAvailability()
        XCTAssertFalse(viewModel.isSecureConversationsAvailable)
    }

    func testMediaPickerButtonEnablingDependsOnSiteConfiguration() async throws {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.secureConversations.getUnreadMessageCount = { 0 }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        let site = try CoreSdkClient.Site.mock(allowedFileSenders: .mock(visitor: true))
        modelEnv.fetchSiteConfigurations = { callback in
            callback(.success(site))
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        await viewModel.start(isTranscriptFetchNeeded: true)

        XCTAssertFalse(viewModel.mediaPickerButtonEnabling.isDisabled)
    }

    func testStartLoadsConfigurationAndChatHistoryAndGetUnreadMessageCount() async {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.uiApplication.applicationState = { .active }
        modelEnv.markUnreadMessagesDelay = { .mock }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.notificationCenter.publisherForNotification = { _ in .mock() }
        enum Call: String, Equatable {
            case fetchChatHistory
            case loadSiteConfiguration
            case getSecureUnreadMessageCount
        }
        var calls: [Call] = []
        modelEnv.fetchChatHistory = {
            calls.append(.fetchChatHistory)
            return []
        }

        modelEnv.fetchSiteConfigurations = { _ in
            calls.append(.loadSiteConfiguration)
        }

        modelEnv.secureConversations.getUnreadMessageCount = {
            calls.append(.getSecureUnreadMessageCount)
            return 1
        }
        modelEnv.startSocketObservation = {}
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
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
        await viewModel.start(isTranscriptFetchNeeded: true)
        let expectedCalls: [Call] = [Call.loadSiteConfiguration, .fetchChatHistory, .getSecureUnreadMessageCount]

        XCTAssertEqual(
            calls.map(\.rawValue),
            expectedCalls.map(\.rawValue)
        )
    }

    func testClearInputsSetMessageTextEmpty() async {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.secureConversations.getUnreadMessageCount = { 0 }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
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
        await viewModel.start(isTranscriptFetchNeeded: true)
        let text = "Test text"
        viewModel.event(.messageTextChanged(text))
        XCTAssertEqual(viewModel.messageText, text)
        viewModel.clearInputs()
        XCTAssertTrue(viewModel.messageText.isEmpty)
    }

    func testValidateMessageReturnsFalseForExpectedCases() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()

        let failedUpload = FileUpload.mock()
        failedUpload.state.value = .error(.generic)

        let inProgressUpload = FileUpload.mock()
        inProgressUpload.state.value = .uploading(progress: .init(with: .zero))

        // Empty text, failed and in-progress uploads, lack of succeeding uploads
        // along with reached limit of uploads will not let validation pass.
        fileUploadListModel.environment.uploader.uploads = [failedUpload, inProgressUpload]
        fileUploadListModel.environment.uploader.limitReached.value = true
        let emptyMessageText = ""

        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        viewModel.event(.messageTextChanged(emptyMessageText))

        XCTAssertFalse(viewModel.validateMessage())
    }

    func testValidateMessageReturnsTrueForSucceedingUpload() throws {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()

        let succeedingUpload = FileUpload.mock()
        succeedingUpload.state.value = try .uploaded(file: .mock())
        fileUploadListModel.environment.uploader.uploads = [succeedingUpload]
        fileUploadListModel.environment.uploader.limitReached.value = false
        // Validation should pass even if text is empty, because file attachments
        // meet criteria.
        let emptyMessageText = ""

        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        viewModel.event(.messageTextChanged(emptyMessageText))

        XCTAssertTrue(viewModel.validateMessage())
    }

    func testValidateMessageReturnsTrueForNonemptyText() throws {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false

        // Validation should pass even for non-empty text.
        let nonEmptyText = "Non empty message."

        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        viewModel.event(.messageTextChanged(nonEmptyText))

        XCTAssertTrue(viewModel.validateMessage())
    }

    func testSendMessageUsesSecureEndpoint() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        let nonEmptyText = "No empty message."
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: "mock", content: $0, attachment: $1)
        }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        enum Call: Equatable { case sendSecureMessagePayload }
        var calls: [Call] = []
        modelEnv.secureConversations.sendMessagePayload = { _, _, _ in
            calls.append(.sendSecureMessagePayload)
            return .mock
        }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        viewModel.event(.messageTextChanged(nonEmptyText))
        viewModel.sendMessage()
        XCTAssertEqual(calls, [.sendSecureMessagePayload])
    }

    func testLoadHistoryAlsoInvokesUnreadMessageCount() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.markUnreadMessagesDelay = { .mock }
        modelEnv.uiApplication.applicationState = { .active }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.notificationCenter.publisherForNotification = { _ in .mock() }
        enum Call: Equatable { case getSecureUnreadMessageCount }
        var calls: [Call] = []
        modelEnv.secureConversations.getUnreadMessageCount = {
            calls.append(.getSecureUnreadMessageCount)
            return 1
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        await viewModel.start(isTranscriptFetchNeeded: true)

        XCTAssertEqual(calls, [.getSecureUnreadMessageCount])
    }

    func testLoadHistoryAddsUnreadMessageDivider() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.maximumUploads = { 2 }
        modelEnv.fetchChatHistory = { [.mock(sender: .operator)] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.secureConversations.getUnreadMessageCount = { 1 }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        modelEnv.uiApplication.applicationState = { .inactive }
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            .mock()
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        await viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()

        XCTAssertTrue(viewModel.historySection.items.contains(where: { item in
            switch item.kind {
            case .unreadMessageDivider:
                return true
            default:
                return false
            }
        }))
    }

    func testSystemMessagesFromWebSocket() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.maximumUploads = { 2 }
        modelEnv.secureConversations.getUnreadMessageCount = { 0 }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let interactor: Interactor = .failing

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: interactor
        )

        modelEnv.fetchChatHistory = {
            let uuid = UUID.mock.uuidString
            let message = CoreSdkClient.Message(
                id: uuid,
                content: "Test",
                sender: .init(type: .system),
                metadata: nil
            )

            interactor.receive(message: message)
            XCTAssertEqual(viewModel.pendingSection.items.count, 1)

            let receivedMessage = viewModel.receivedMessages[uuid]
            XCTAssertNotNil(receivedMessage)

            if case let .socket(innerMessage) = receivedMessage?.first {
                XCTAssertEqual(innerMessage.id, uuid)
                XCTAssertEqual(innerMessage.sender.type, .system)
            } else {
                XCTFail("Message should come from socket")
            }

            return [ChatMessage(with: message)]
        }

        await viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
    }

    func testWelcomeMessagesFromWebSocket() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.fetchChatHistory = { [] }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.maximumUploads = { 2 }
        modelEnv.secureConversations.getUnreadMessageCount = { 0 }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let interactor: Interactor = .failing

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: interactor
        )

        modelEnv.fetchChatHistory = {
            let uuid = UUID.mock.uuidString
            let message = CoreSdkClient.Message(
                id: uuid,
                content: "Welcome",
                sender: .init(type: .operator),
                metadata: nil
            )

            interactor.receive(message: message)
            XCTAssertEqual(viewModel.pendingSection.items.count, 1)

            let receivedMessage = viewModel.receivedMessages[uuid]
            XCTAssertNotNil(receivedMessage)

            if case let .socket(innerMessage) = receivedMessage?.first {
                XCTAssertEqual(innerMessage.id, uuid)
                XCTAssertEqual(innerMessage.sender.type, .operator)
            } else {
                XCTFail("Message should come from socket")
            }
            return [ChatMessage(with: message)]
        }

        await viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
    }

    func testIsSecureConversationsAvailableIsFalseIsDueToEmptyQueue() async {
        var modelEnvironment = TranscriptModel.Environment.failing
        modelEnvironment.uiApplication = .mock
        modelEnvironment.fileManager = .mock
        modelEnvironment.maximumUploads = { 2 }
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        modelEnvironment.createEntryWidget = { _ in .mock() }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnvironment.log = logger
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.log = logger
        availabilityEnv.getQueues = { [] }
        availabilityEnv.isAuthenticated = { true }
        availabilityEnv.queuesMonitor = .mock(getQueues: availabilityEnv.getQueues)
        availabilityEnv.getCurrentEngagement = { .mock() }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
        await model.checkSecureConversationsAvailability()
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsFalseDueToUnauthenticated() async {
        var modelEnvironment = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnvironment.uiApplication = .mock
        modelEnvironment.log = logger
        modelEnvironment.fileManager = .mock
        modelEnvironment.maximumUploads = { 2 }
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        modelEnvironment.createEntryWidget = { _ in .mock() }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.log = logger
        availabilityEnv.getQueues = { [.mock()] }
        availabilityEnv.isAuthenticated = { false }
        availabilityEnv.queuesMonitor = .mock(getQueues: availabilityEnv.getQueues)
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
        await model.checkSecureConversationsAvailability()
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsFalseDueTogetQueuesError() async {
        var modelEnvironment = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        modelEnvironment.uiApplication = .mock
        modelEnvironment.log = logger
        modelEnvironment.fileManager = .mock
        modelEnvironment.maximumUploads = { 2 }
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        modelEnvironment.createEntryWidget = { _ in .mock() }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        let mockError = NSError(domain: "", code: 1)
        availabilityEnv.getQueues = { throw mockError }
        availabilityEnv.isAuthenticated = { false }
        availabilityEnv.queuesMonitor = .mock(getQueues: availabilityEnv.getQueues)
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
        await model.checkSecureConversationsAvailability()
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsTrue() async {
        var modelEnvironment = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnvironment.uiApplication = .mock
        modelEnvironment.log = logger
        modelEnvironment.fileManager = .mock
        modelEnvironment.maximumUploads = { 2 }
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        modelEnvironment.createEntryWidget = { _ in .mock() }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.log = logger
        availabilityEnv.getQueues = { [.mock()] }
        availabilityEnv.isAuthenticated = { true }
        availabilityEnv.queuesMonitor = .mock(getQueues: availabilityEnv.getQueues)
        availabilityEnv.getCurrentEngagement = { .mock() }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
        await model.checkSecureConversationsAvailability()
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testSetIsSecureConversationsAvailableCallsAction() throws {
        var modelEnvironment = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnvironment.uiApplication = .mock
        modelEnvironment.log = logger
        modelEnvironment.fileManager = .mock
        modelEnvironment.maximumUploads = { 2 }
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        modelEnvironment.createEntryWidget = { _ in .mock() }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.log = logger
        availabilityEnv.getQueues = { [.mock()] }
        availabilityEnv.isAuthenticated = { true }
        availabilityEnv.queuesMonitor = .mock(getQueues: availabilityEnv.getQueues)
        availabilityEnv.getCurrentEngagement = { .mock() }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )
        var actions: [TranscriptModel.Action] = []
        model.action = {
            actions.append($0)
        }
        model.setIsSecureConversationsAvailable(true)
        XCTAssertEqual(actions.count, 1)
        let receivedAction = try XCTUnwrap(actions.first)
        switch receivedAction {
        case .transcript(.messageCenterAvailabilityUpdated):
            break
        default:
            XCTFail("Unexpected action: \(receivedAction)")
        }
    }

    func testLoadHistoryAlsoInvokesSecureMarkMessagesAsReadIfShouldNotShowLeaveSecureConversationDialog() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, function in function() }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchChatHistory = { [.mock(), .mock(), .mock()] }
        modelEnv.secureConversations.getUnreadMessageCount = { 5 }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        modelEnv.uiApplication.applicationState = { .active }
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        modelEnv.secureConversations.markMessagesAsRead = {
            calls.append(.secureMarkMessagesAsRead)
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: 5),
            interactor: .failing
        )

        viewModel.isViewActive.value = true

        await viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
        // Will be removed when combine and async bridge is implemented
        await waitUntil {
            calls == [.secureMarkMessagesAsRead]
        }

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }

    func testLoadHistoryNotInvokesSecureMarkMessagesAsReadIfShouldShowLeaveSecureConversationDialog() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, function in function() }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchChatHistory = { [.mock(), .mock(), .mock()] }
        modelEnv.secureConversations.getUnreadMessageCount = { 5 }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        modelEnv.secureConversations.markMessagesAsRead = {
            calls.append(.secureMarkMessagesAsRead)
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in true }
        modelEnv.markUnreadMessagesDelay = { .zero }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        await viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()

        XCTAssertTrue(calls.isEmpty)
    }

    func testLeaveCurrentConversationAlertDeclineMarkMessagesAsRead() async {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, function in function() }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchChatHistory = { [.mock(), .mock(), .mock()] }
        modelEnv.secureConversations.getUnreadMessageCount = { 5 }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.uiApplication.applicationState = { .active }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        modelEnv.secureConversations.markMessagesAsRead = {
            calls.append(.secureMarkMessagesAsRead)
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in true }
        modelEnv.leaveCurrentSecureConversation = .nop
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
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

        viewModel.isViewActive.value = true

        viewModel.engagementAction = { action in
            if case .showAlert(let type) = action, case let .leaveCurrentConversation(_, declined) = type {
                declined?()
            }
        }

        await viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()

        // Will be removed when fetchChatHistory is converted to async
        await waitUntil {
            calls == [.secureMarkMessagesAsRead]
        }

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }

    func testReceiveMessageMarksMessagesAsRead() async {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var modelEnv = TranscriptModel.Environment.failing
        let interactor: Interactor = .mock()
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.uiApplication.applicationState = { .active }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.getQueues = { [] }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.secureConversations.getUnreadMessageCount = { 1 }
        modelEnv.maximumUploads = { 2 }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, callback in callback() }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.uiApplication.applicationState = { .active }
        modelEnv.secureConversations.markMessagesAsRead = {
            calls.append(.secureMarkMessagesAsRead)
        }
        modelEnv.fetchChatHistory = { [.mock()] }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.interactor = interactor
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: interactor
        )

        viewModel.isViewActive.value = true

        await viewModel.start(isTranscriptFetchNeeded: true)

        let uuid = UUID.mock.uuidString
        let message = CoreSdkClient.Message(
            id: uuid,
            content: "Test",
            sender: .init(type: .system),
            metadata: nil
        )
        interactor.receive(message: message)

        // TO-DO will be removed with combine/async bridge
        await waitUntil {
            calls.contains(.secureMarkMessagesAsRead)
        }

        XCTAssertTrue(calls.contains(.secureMarkMessagesAsRead))
    }

    func testLeaveCurrentConversationIfShouldShowLeaveScDialogIsFalseAndCalledFromTopBanner() {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { config in .mock(configuration: config) }

        enum Call: Equatable {
            case shouldShowCalledFromTopBanner, shouldShowCalledFromTranscript
            case switchToEngagement(EngagementKind)
        }
        var calls: [Call] = []
        modelEnv.shouldShowLeaveSecureConversationDialog = { source in
            switch source {
            case .entryWidgetTopBanner:
                calls.append(.shouldShowCalledFromTopBanner)
            case .transcriptOpened:
                calls.append(.shouldShowCalledFromTranscript)
            }
            return false
        }
        modelEnv.switchToEngagement = .init { kind in
            calls.append(.switchToEngagement(kind))
        }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
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
        viewModel.engagementAction = { action in
            guard case .showAlert(.leaveCurrentConversation) = action else { return }
            XCTFail("`.showAlert(.leaveCurrentConversation)` action should not be called")
        }

        viewModel.entryWidget?.mediaTypeSelected(.init(type: .chat))

        XCTAssertEqual(calls, [.shouldShowCalledFromTopBanner, .switchToEngagement(.chat)])
    }

    func testLeaveCurrentConversationIfShouldShowLeaveScDialogIsTrueAndCalledFromTopBanner() {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { config in .mock(configuration: config) }

        enum Call: Equatable {
            case shouldShowCalledFromTopBanner, shouldShowCalledFromTranscript, showLeaveCurrentConversationDialog
            case switchToEngagement(EngagementKind)
        }
        var calls: [Call] = []
        modelEnv.shouldShowLeaveSecureConversationDialog = { source in
            switch source {
            case .entryWidgetTopBanner:
                calls.append(.shouldShowCalledFromTopBanner)
            case .transcriptOpened:
                calls.append(.shouldShowCalledFromTranscript)
            }
            return true
        }
        modelEnv.switchToEngagement = .init { kind in
            calls.append(.switchToEngagement(kind))
        }
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock(getQueues: modelEnv.getQueues),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
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
        viewModel.engagementAction = { action in
            guard case .showAlert(.leaveCurrentConversation(let confirmed, _)) = action else {
                XCTFail("action should be `.showAlert(.leaveCurrentConversation)`")
                return
            }
            calls.append(.showLeaveCurrentConversationDialog)
            confirmed()
        }

        viewModel.entryWidget?.mediaTypeSelected(.init(type: .chat))

        XCTAssertEqual(calls, [.shouldShowCalledFromTopBanner, .showLeaveCurrentConversationDialog, .switchToEngagement(.chat)])
    }
}
