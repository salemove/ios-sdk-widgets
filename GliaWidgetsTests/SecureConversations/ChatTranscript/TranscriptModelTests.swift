@testable import GliaWidgets
import XCTest
import Combine

final class SecureConversationsTranscriptModelTests: XCTestCase {
    typealias TranscriptModel = SecureConversations.TranscriptModel
    typealias FileUploadListViewModel = SecureConversations.FileUploadListViewModel

    func testEmptyQueueSetsIsSecureConversationsAvailableToFalse() {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback([], nil) }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        XCTAssertFalse(viewModel.isSecureConversationsAvailable)
    }

    func testUnauthenticatedVisitorSetsIsSecureConversationsAvailableToFalse() {
        var modelEnv = TranscriptModel.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        modelEnv.log = logger
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback(nil, .mock()) }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { false },
            log: logger,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        XCTAssertFalse(viewModel.isSecureConversationsAvailable)
    }

    func testMediaPickerButtonEnablingDependsOnSiteConfiguration() throws {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let site = try CoreSdkClient.Site.mock(allowedFileSenders: .mock(visitor: true))
        modelEnv.fetchSiteConfigurations = { callback in
            callback(.success(site))
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.start(isTranscriptFetchNeeded: true)

        XCTAssertFalse(viewModel.mediaPickerButtonEnabling.isDisabled)
    }

    func testStartLoadsConfigurationAndChatHistoryAndGetUnreadMessageCount() {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.createEntryWidget = { _ in .mock() }
        enum Call: String, Equatable {
            case fetchChatHistory
            case loadSiteConfiguration
            case getSecureUnreadMessageCount
        }
        var calls: [Call] = []
        modelEnv.fetchChatHistory = { _ in
            calls.append(.fetchChatHistory)
        }

        modelEnv.fetchSiteConfigurations = { _ in
            calls.append(.loadSiteConfiguration)
        }

        modelEnv.getSecureUnreadMessageCount = { _ in calls.append(.getSecureUnreadMessageCount)
        }
        modelEnv.startSocketObservation = {}
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )
        viewModel.start(isTranscriptFetchNeeded: true)
        XCTAssertEqual(
            calls.map(\.rawValue),
            [Call.loadSiteConfiguration, .getSecureUnreadMessageCount, .fetchChatHistory].map(\.rawValue)
        )
    }

    func testClearInputsSetMessageTextEmpty() {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )
        viewModel.start(isTranscriptFetchNeeded: true)
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
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: "mock", content: $0, attachment: $1)
        }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        enum Call: Equatable { case sendSecureMessagePayload }
        var calls: [Call] = []
        modelEnv.sendSecureMessagePayload = { _, _, _ in
            calls.append(.sendSecureMessagePayload)
            return .mock
        }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.event(.messageTextChanged(nonEmptyText))
        viewModel.sendMessage()
        XCTAssertEqual(calls, [.sendSecureMessagePayload])
    }

    func testLoadHistoryAlsoInvokesUnreadMessageCount() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        enum Call: Equatable { case getSecureUnreadMessageCount }
        var calls: [Call] = []
        modelEnv.getSecureUnreadMessageCount = { _ in
            calls.append(.getSecureUnreadMessageCount)
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.start(isTranscriptFetchNeeded: true)
        XCTAssertEqual(calls, [.getSecureUnreadMessageCount])
    }

    func testLoadHistoryAddsUnreadMessageDivider() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.fetchChatHistory = { callback in
            callback(.success([.mock(sender: .operator)]))
        }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { callback in
            callback(.success(1))
        }
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
        modelEnv.combineScheduler.global = { .global() }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.start(isTranscriptFetchNeeded: true)
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

    func testSystemMessagesFromWebSocket() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.getSecureUnreadMessageCount = { callback in
            callback(.success(0))
        }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: interactor
        )

        modelEnv.fetchChatHistory = { _ in
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
        }

        viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
    }

    func testWelcomeMessagesFromWebSocket() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.maximumUploads = { 2 }
        modelEnv.getSecureUnreadMessageCount = { callback in
            callback(.success(0))
        }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: interactor
        )

        modelEnv.fetchChatHistory = { _ in
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
        }

        viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
    }

    func testIsSecureConversationsAvailableIsFalseIsDueToEmptyQueue() {
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
        availabilityEnv.listQueues = { callback in
            callback([], nil)
        }
        availabilityEnv.isAuthenticated = { true }
        availabilityEnv.queuesMonitor = .mock(listQueues: availabilityEnv.listQueues)
        availabilityEnv.getCurrentEngagement = { .mock() }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: .failing
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsFalseDueToUnauthenticated() {
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
        availabilityEnv.listQueues = { callback in
            callback([.mock()], nil)
        }
        availabilityEnv.isAuthenticated = { false }
        availabilityEnv.queuesMonitor = .mock(listQueues: availabilityEnv.listQueues)
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: .failing
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsFalseDueToListQueuesError() {
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
        availabilityEnv.listQueues = { callback in
            callback(nil, .mock())
        }
        availabilityEnv.isAuthenticated = { false }
        availabilityEnv.queuesMonitor = .mock(listQueues: availabilityEnv.listQueues)
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: .failing
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsTrue() {
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
        availabilityEnv.listQueues = { callback in
            callback([.mock()], nil)
        }
        availabilityEnv.isAuthenticated = { true }
        availabilityEnv.queuesMonitor = .mock(listQueues: availabilityEnv.listQueues)
        availabilityEnv.getCurrentEngagement = { .mock() }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            interactor: .failing
        )
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
        availabilityEnv.listQueues = { callback in
            callback([.mock()], nil)
        }
        availabilityEnv.isAuthenticated = { true }
        availabilityEnv.queuesMonitor = .mock(listQueues: availabilityEnv.listQueues)
        availabilityEnv.getCurrentEngagement = { .mock() }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
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

    func testLoadHistoryAlsoInvokesSecureMarkMessagesAsReadIfShouldNotShowLeaveSecureConversationDialog() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, function in function() }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchChatHistory = { $0(.success([.mock(), .mock(), .mock()])) }
        modelEnv.getSecureUnreadMessageCount = { $0(.success(5)) }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        modelEnv.uiApplication.applicationState = { .active }
        // Once MOB-4008 is ready, this test must be rewritten using the Combine Scheduler tools.
        let expectation = expectation(description: "Message marked as read")
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        modelEnv.secureMarkMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            expectation.fulfill()
            return .mock
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { false }
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        modelEnv.combineScheduler.global = { .global() }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }

    func testLoadHistoryNotInvokesSecureMarkMessagesAsReadIfShouldShowLeaveSecureConversationDialog() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, function in function() }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchChatHistory = { $0(.success([.mock(), .mock(), .mock()])) }
        modelEnv.getSecureUnreadMessageCount = { $0(.success(5)) }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        // Once MOB-4008 is ready, this test must be rewritten using the Combine Scheduler tools.
        let expectation = expectation(description: "No Message marked as read")
        expectation.isInverted = true
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        modelEnv.secureMarkMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            expectation.fulfill()
            return .mock
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { true }
        modelEnv.markUnreadMessagesDelay = { .zero }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
        wait(for: [expectation], timeout: 0.1)

        XCTAssertTrue(calls.isEmpty)
    }

    func testLeaveCurrentConversationAlertDeclineMarkMessagesAsRead() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, function in function() }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchChatHistory = { $0(.success([.mock(), .mock(), .mock()])) }
        modelEnv.getSecureUnreadMessageCount = { $0(.success(5)) }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.startSocketObservation = {}
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.uiApplication.applicationState = { .active }
        // Once MOB-4008 is ready, this test must be rewritten using the Combine Scheduler tools.
        let expectation = expectation(description: "Message marked as read")
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        modelEnv.secureMarkMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            expectation.fulfill()
            return .mock
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { true }
        modelEnv.leaveCurrentSecureConversation = .nop
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        modelEnv.combineScheduler.global = { .global() }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: .failing
        )

        viewModel.engagementAction = { action in
            if case .showAlert(let type) = action, case let .leaveCurrentConversation(_, declined) = type {
                declined?()
            }
        }

        viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()
        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }

    func testReceiveMessageMarksMessagesAsRead() {
        // Once MOB-4008 is ready, this test must be rewritten using the Combine Scheduler tools.
        let expectation = expectation(description: "Message marked as read")
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var modelEnv = TranscriptModel.Environment.failing
        let interactor: Interactor = .mock()
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.uiApplication.applicationState = { .active }
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.getSecureUnreadMessageCount = { $0(.success(0)) }
        modelEnv.maximumUploads = { 2 }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, callback in callback() }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.uiApplication.applicationState = { .active }
        modelEnv.secureMarkMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            expectation.fulfill()
            return .mock
        }
        modelEnv.fetchChatHistory = { completion in
            completion(.success([.mock()]))
        }
        modelEnv.shouldShowLeaveSecureConversationDialog = { false }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        modelEnv.interactor = interactor
        modelEnv.markUnreadMessagesDelay = { .zero }
        modelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        modelEnv.combineScheduler.global = { .global() }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            isAuthenticated: { true },
            log: .failing,
            queuesMonitor: .mock(listQueues: modelEnv.listQueues),
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
            interactor: interactor
        )

        viewModel.start(isTranscriptFetchNeeded: true)
        scheduler.run()

        let uuid = UUID.mock.uuidString
        let message = CoreSdkClient.Message(
            id: uuid,
            content: "Test",
            sender: .init(type: .system),
            metadata: nil
        )
        interactor.receive(message: message)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }
}
