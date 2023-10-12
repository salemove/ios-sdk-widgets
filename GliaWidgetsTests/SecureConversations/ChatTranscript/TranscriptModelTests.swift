@testable import GliaWidgets
import XCTest

final class SecureConversationsTranscriptModelTests: XCTestCase {
    typealias TranscriptModel = SecureConversations.TranscriptModel
    typealias FileUploadListViewModel = SecureConversations.FileUploadListViewModel

    func testEmptyQueueSetsIsSecureConversationsAvailableToFalse() {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback([], nil) }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )
        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )

        XCTAssertFalse(viewModel.isSecureConversationsAvailable)
    }

    func testUnauthenticatedVisitorSetsIsSecureConversationsAvailableToFalse() {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { callback in callback(nil, .mock()) }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { false }
        )
        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )

        XCTAssertFalse(viewModel.isSecureConversationsAvailable)
    }

    func testMediaPickerButtonVisibilityDependsOnSiteConfiguration() throws {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { _ in }
        modelEnv.fetchChatHistory = { _ in }
        modelEnv.getSecureUnreadMessageCount = { _ in }
        modelEnv.startSocketObservation = {}
        let site = try CoreSdkClient.Site.mock(allowedFileSenders: .mock(visitor: true))
        modelEnv.fetchSiteConfigurations = { callback in
            callback(.success(site))
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )

        viewModel.start()

        XCTAssertFalse(viewModel.mediaPickerButtonVisibility.isHidden)
    }

    func testStartLoadsConfigurationAndChatHistoryAndGetUnreadMessageCount() {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.listQueues = { _ in }
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
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )
        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        viewModel.start()
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
        modelEnv.getSecureUnreadMessageCount = { _ in  }
        modelEnv.startSocketObservation = {}
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )
        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        viewModel.start()
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
        modelEnv.getSecureUnreadMessageCount = { _ in  }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
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
        modelEnv.getSecureUnreadMessageCount = { _ in  }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
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
        modelEnv.getSecureUnreadMessageCount = { _ in  }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
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
        modelEnv.getSecureUnreadMessageCount = { _ in  }
        modelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: "mock", content: $0, attachment: $1)
        }
        enum Call: Equatable { case sendSecureMessagePayload }
        var calls: [Call] = []
        modelEnv.sendSecureMessagePayload = { _, _, _ in
            calls.append(.sendSecureMessagePayload)
            return .mock
        }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
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
        enum Call: Equatable { case getSecureUnreadMessageCount }
        var calls: [Call] = []
        modelEnv.getSecureUnreadMessageCount = { _ in
            calls.append(.getSecureUnreadMessageCount)
        }

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )

        viewModel.start()
        XCTAssertEqual(calls, [.getSecureUnreadMessageCount])
    }

    func testLoadHistoryAddsUnreadMessageDivider() {
        var modelEnv = TranscriptModel.Environment.failing
        let fileUploadListModel = FileUploadListViewModel.mock()
        fileUploadListModel.environment.uploader.limitReached.value = false
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in fileUploadListModel }
        modelEnv.listQueues = { _ in }
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
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )

        viewModel.start()
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
        modelEnv.getSecureUnreadMessageCount = { callback in
            callback(.success(0))
        }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, callback in }
        modelEnv.loadChatMessagesFromHistory = { true }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let interactor: Interactor = .failing

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: interactor,
            alertConfiguration: .mock()
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

        viewModel.start()
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
        modelEnv.getSecureUnreadMessageCount = { callback in
            callback(.success(0))
        }
        modelEnv.startSocketObservation = {}
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler

        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: modelEnv.listQueues,
            queueIds: modelEnv.queueIds,
            isAuthenticated: { true }
        )

        let interactor: Interactor = .failing

        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: interactor,
            alertConfiguration: .mock()
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

        viewModel.start()
        scheduler.run()
    }

    func testIsSecureConversationsAvailableIsFalseIsDueToEmptyQueue() {
        var modelEnvironment = TranscriptModel.Environment.failing
        modelEnvironment.fileManager = .mock
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.listQueues = { callback in
            callback([], nil)
        }
        availabilityEnv.isAuthenticated = { true }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsFalseDueToUnauthenticated() {
        var modelEnvironment = TranscriptModel.Environment.failing
        modelEnvironment.fileManager = .mock
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.listQueues = { callback in
            callback([.mock()], nil)
        }
        availabilityEnv.isAuthenticated = { false }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsFalseDueToListQueuesError() {
        var modelEnvironment = TranscriptModel.Environment.failing
        modelEnvironment.fileManager = .mock
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.listQueues = { callback in
            callback(nil, .mock())
        }
        availabilityEnv.isAuthenticated = { false }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testIsSecureConversationsAvailableIsTrue() {
        var modelEnvironment = TranscriptModel.Environment.failing
        modelEnvironment.fileManager = .mock
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.listQueues = { callback in
            callback([.mock()], nil)
        }
        availabilityEnv.isAuthenticated = { true }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )
        XCTAssertFalse(model.isSecureConversationsAvailable)
    }

    func testSetIsSecureConversationsAvailableCallsAction() throws {
        var modelEnvironment = TranscriptModel.Environment.failing
        modelEnvironment.fileManager = .mock
        modelEnvironment.createFileUploadListModel = {
            .mock(environment: $0)
        }
        var availabilityEnv = SecureConversations.Availability.Environment.failing
        availabilityEnv.listQueues = { callback in
            callback([.mock()], nil)
        }
        availabilityEnv.isAuthenticated = { true }
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnvironment,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
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
}
