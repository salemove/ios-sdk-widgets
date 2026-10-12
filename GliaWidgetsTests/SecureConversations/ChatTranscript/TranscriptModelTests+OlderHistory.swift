@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

extension SecureConversationsTranscriptModelTests {
    private typealias Completion = (Result<CoreSdkClient.ChatHistoryPage, CoreSdkClient.GliaCoreError>) -> Void

    func test_olderHistoryRequestedWhenNothingOlderDoesNotFetch() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(olderPage: nil)

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertTrue(spy.actions.isEmpty)
    }

    func test_olderHistoryRequestedWhileLoadingDoesNotFetchAgain() {
        var fetchCount = 0
        let (viewModel, _) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _, _ in fetchCount += 1 }
        )

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(fetchCount, 1)
    }

    func test_olderHistoryRequestedPassesStoredKeyAndPrependsOlderMessagesInOrder() {
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { key, completion in
                requestedKeys.append(key)
                completion(.success(.init(messages: [.mock(id: "msg-1"), .mock(id: "msg-2")], olderPage: nil)))
            }
        )
        viewModel.historySection.set([chatItem(id: "msg-3")])

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(requestedKeys, [ChatViewModelTests.olderPage2])
        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2", "msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: false, isLoading: false)
        ])
        XCTAssertEqual(spy.prependedRows, [.init(count: 2, section: viewModel.historySection.index)])
    }

    func test_olderHistoryRequestedDropsMessagesAlreadyShown() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _, completion in
                completion(.success(.init(messages: [.mock(id: "msg-1"), .mock(id: "MSG-2")])))
            }
        )
        viewModel.historySection.set([chatItem(id: "msg-2"), ChatItem(kind: .unreadMessageDivider)])

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2"])
        XCTAssertEqual(spy.prependedRows, [.init(count: 1, section: viewModel.historySection.index)])
    }

    func test_olderHistoryRequestedFailureStopsLoadingKeepsHistoryAndKey() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _, completion in completion(.failure(CoreSdkClient.GliaCoreError(reason: "offline"))) }
        )
        viewModel.historySection.set([chatItem(id: "msg-3")])

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: true, isLoading: false)
        ])
        XCTAssertTrue(spy.prependedRows.isEmpty)
        XCTAssertEqual(viewModel.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
    }

    func test_loadHistoryStoresKeyFromFirstPage() {
        let withKey = loadHistoryInTranscriptModel(olderPage: ChatViewModelTests.olderPage2)
        XCTAssertEqual(withKey.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
        XCTAssertEqual(withKey.model.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)

        let withoutKey = loadHistoryInTranscriptModel(olderPage: nil)
        XCTAssertEqual(withoutKey.spy.olderHistoryStates.last, .init(canLoad: false, isLoading: false))
    }

    func test_loadHistoryFailureLeavesNoKey() {
        let result = loadHistoryInTranscriptModel(
            olderPage: nil,
            fetchChatHistory: { $0(.failure(CoreSdkClient.GliaCoreError(reason: "offline"))) }
        )

        XCTAssertNil(result.model.olderHistoryLoader.olderPage)
    }

    func test_messagesWithUnreadCountPassesOlderPageThrough() {
        let page = CoreSdkClient.ChatHistoryPage(messages: [.mock(id: "msg-1")], olderPage: ChatViewModelTests.olderPage2)

        let withCount = try? SecureConversations.MessagesWithUnreadCountLoader.messageWithUnreadCountResult(
            messageResult: .success(page),
            unreadCountResult: .success(3)
        ).get()
        let withoutCount = try? SecureConversations.MessagesWithUnreadCountLoader.messageWithUnreadCountResult(
            messageResult: .success(page),
            unreadCountResult: .failure(SecureConversations.MessagesWithUnreadCountLoader.TimeoutError())
        ).get()

        XCTAssertEqual(withCount?.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(withCount?.unreadCount, 3)
        XCTAssertEqual(withoutCount?.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(withoutCount?.messages.map(\.id), ["msg-1"])
    }

    // MARK: - Migration

    func test_migrateFromChatTakesOverKeyAndClearsItInChatModel() {
        let chat = ChatViewModelTests.makeOlderHistoryViewModel(history: [.mock(id: "msg-2")], olderPage: ChatViewModelTests.olderPage2)
        chat.viewModel.start()
        let (transcript, spy) = makeOlderHistoryTranscriptModel(olderPage: nil)
        transcript.environment.fetchSiteConfigurations = { _ in }
        transcript.environment.shouldShowLeaveSecureConversationDialog = { _ in false }

        transcript.migrate(from: chat.viewModel)

        XCTAssertEqual(transcript.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
        XCTAssertNil(chat.viewModel.olderHistoryLoader.olderPage)
    }

    func test_migrateToChatHandsOverKeyAndClearsItInTranscriptModel() {
        let (transcript, _) = makeOlderHistoryTranscriptModel(olderPage: ChatViewModelTests.olderPage2)
        transcript.historySection.set([chatItem(id: "msg-2")])
        let chat = ChatViewModelTests.makeOlderHistoryViewModel(olderPage: nil)

        chat.viewModel.migrate(from: transcript)

        XCTAssertEqual(chat.viewModel.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(chat.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
        XCTAssertNil(transcript.olderHistoryLoader.olderPage)
    }

    func test_migrateToChatDropsOlderPageArrivingInTranscriptModelAfterSwap() {
        var pendingCompletions: [Completion] = []
        let (transcript, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _, completion in pendingCompletions.append(completion) }
        )
        transcript.historySection.set([chatItem(id: "msg-2")])
        transcript.event(.loadOlderHistoryRequested)
        let chat = ChatViewModelTests.makeOlderHistoryViewModel(olderPage: nil)
        chat.viewModel.migrate(from: transcript)
        spy.actions.removeAll()

        pendingCompletions.first?(.success(.init(messages: [.mock(id: "msg-1")], olderPage: ChatViewModelTests.olderPage3)))

        XCTAssertTrue(spy.actions.isEmpty)
        XCTAssertEqual(chat.viewModel.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertFalse(chat.viewModel.olderHistoryLoader.isLoading)
    }
}

// MARK: - Helpers

extension SecureConversationsTranscriptModelTests {
    private func chatItem(id: String) -> ChatItem {
        ChatItem(kind: .visitorMessage(.mock(id: id), status: nil))
    }

    private func loadHistoryInTranscriptModel(
        olderPage: CoreSdkClient.OlderChatHistoryPage?,
        fetchChatHistory: CoreSdkClient.FetchChatHistory? = nil
    ) -> (model: TranscriptModel, spy: ChatViewModelTests.OlderHistoryActionSpy) {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(olderPage: nil)
        var modelEnv = viewModel.environment
        modelEnv.fetchChatHistory = fetchChatHistory ?? { $0(.success(.init(messages: [.mock(id: "msg-1")], olderPage: olderPage))) }
        modelEnv.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        modelEnv.fetchSiteConfigurations = { _ in }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        let scheduler = CoreSdkClient.ReactiveSwift.TestScheduler()
        modelEnv.messagesWithUnreadCountLoaderScheduler = scheduler
        let model = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: viewModel.availability,
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>(with: .zero),
            interactor: .failing
        )
        model.action = { spy.actions.append($0) }

        model.start(isTranscriptFetchNeeded: true)
        scheduler.run()
        return (model, spy)
    }

    private func makeOlderHistoryTranscriptModel(
        olderPage: CoreSdkClient.OlderChatHistoryPage?,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _, _ in
            XCTFail("Unexpected fetchOlderChatHistory")
        }
    ) -> (viewModel: TranscriptModel, spy: ChatViewModelTests.OlderHistoryActionSpy) {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.log = .mock
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { callback in callback(.success([])) }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchOlderChatHistory = fetchOlderChatHistory
        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: modelEnv.getQueues,
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(),
            getCurrentEngagement: { .mock() }
        )
        let viewModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: modelEnv,
            availability: .init(environment: availabilityEnv),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>(with: .zero),
            interactor: .failing
        )
        viewModel.olderHistoryLoader.replaceOlderPage(olderPage)
        let spy = ChatViewModelTests.OlderHistoryActionSpy()
        viewModel.action = { spy.actions.append($0) }
        return (viewModel, spy)
    }
}
