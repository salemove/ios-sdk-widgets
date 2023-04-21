@testable import GliaWidgets
import XCTest

final class TranscriptModelTests: XCTestCase {
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
            deliveredStatusText: ""
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
        enum Call: Equatable { case sendSecureMessage }
        var calls: [Call] = []
        modelEnv.sendSecureMessage = { _, _, _, _ in
            calls.append(.sendSecureMessage)
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
            deliveredStatusText: ""
        )

        viewModel.event(.messageTextChanged(nonEmptyText))
        viewModel.sendMessage()
        XCTAssertEqual(calls, [.sendSecureMessage])
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
            deliveredStatusText: ""
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
        modelEnv.gcd.mainQueue.asyncAfterDeadline = { _, callback in }
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
            deliveredStatusText: ""
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
}
