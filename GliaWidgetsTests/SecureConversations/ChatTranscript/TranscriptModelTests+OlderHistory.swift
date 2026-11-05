@testable import GliaWidgets
@_spi(GliaWidgets) internal import GliaCoreSDK
import XCTest

extension SecureConversationsTranscriptModelTests {
    @MainActor
    func test_olderHistoryRequestedWhenNothingOlderDoesNotFetch() async {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(olderPage: nil)

        viewModel.event(.loadOlderHistoryRequested)
        await Task.yield()

        XCTAssertTrue(spy.actions.isEmpty)
    }

    @MainActor
    func test_olderHistoryRequestedWhileLoadingDoesNotFetchAgain() async {
        var fetchCount = 0
        let gate = OlderPageGate()
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _ in
                fetchCount += 1
                return await gate.wait()
            }
        )

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)
        await waitUntil { fetchCount == 1 }
        await Task.yield()

        XCTAssertEqual(fetchCount, 1)
        XCTAssertEqual(spy.olderHistoryStates, [.init(canLoad: true, isLoading: true)])

        gate.open(with: .init(messages: []))
        await viewModel.olderHistoryLoader.currentLoad?.value
    }

    @MainActor
    func test_olderHistoryRequestedPassesStoredKeyAndPrependsOlderMessagesInOrder() async {
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { key in
                requestedKeys.append(key)
                return .init(messages: [.mock(id: "msg-1"), .mock(id: "msg-2")], olderPage: nil)
            }
        )
        viewModel.historySection.set([chatItem(id: "msg-3")])

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertEqual(requestedKeys, [ChatViewModelTests.olderPage2])
        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2", "msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: false, isLoading: false)
        ])
        XCTAssertEqual(spy.prependedRows, [.init(count: 2, section: viewModel.historySection.index)])
    }

    @MainActor
    func test_olderHistoryRequestedDropsMessagesAlreadyShown() async {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _ in
                .init(messages: [.mock(id: "msg-1"), .mock(id: "MSG-2")])
            }
        )
        viewModel.historySection.set([chatItem(id: "msg-2"), ChatItem(kind: .unreadMessageDivider)])

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2"])
        XCTAssertEqual(spy.prependedRows, [.init(count: 1, section: viewModel.historySection.index)])
    }

    @MainActor
    func test_olderHistoryRequestedFailureStopsLoadingKeepsHistoryAndKey() async {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _ in throw CoreSdkClient.GliaCoreError(reason: "offline") }
        )
        viewModel.historySection.set([chatItem(id: "msg-3")])

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: true, isLoading: false)
        ])
        XCTAssertTrue(spy.prependedRows.isEmpty)
        XCTAssertEqual(viewModel.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
    }

    @MainActor
    func test_loadHistoryStoresKeyFromFirstPage() async {
        let withKey = await loadHistoryInTranscriptModel(olderPage: ChatViewModelTests.olderPage2)
        XCTAssertEqual(withKey.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
        XCTAssertEqual(withKey.model.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)

        let withoutKey = await loadHistoryInTranscriptModel(olderPage: nil)
        XCTAssertEqual(withoutKey.spy.olderHistoryStates.last, .init(canLoad: false, isLoading: false))
    }

    @MainActor
    func test_loadHistoryFailureLeavesNoKeyAndDetachesPullToLoad() async {
        let result = await loadHistoryInTranscriptModel(
            olderPage: nil,
            fetchChatHistory: { throw CoreSdkClient.GliaCoreError(reason: "offline") }
        )

        XCTAssertNil(result.model.olderHistoryLoader.olderPage)
        XCTAssertEqual(result.spy.olderHistoryStates, [.init(canLoad: false, isLoading: false)])
    }

    func test_messagesWithUnreadCountPassesOlderPageThrough() async throws {
        let page = CoreSdkClient.ChatHistoryPage(messages: [.mock(id: "msg-1")], olderPage: ChatViewModelTests.olderPage2)

        let withCount = try await SecureConversations.MessagesWithUnreadCountLoader(
            environment: .init(getSecureUnreadMessageCount: { 3 }, fetchChatHistory: { page })
        ).loadMessagesWithUnreadCount()
        let withoutCount = try await SecureConversations.MessagesWithUnreadCountLoader(
            environment: .init(
                getSecureUnreadMessageCount: { throw CoreSdkClient.GliaCoreError(reason: "offline") },
                fetchChatHistory: { page }
            )
        ).loadMessagesWithUnreadCount()

        XCTAssertEqual(withCount.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(withCount.unreadCount, 3)
        XCTAssertEqual(withoutCount.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(withoutCount.unreadCount, 0)
        XCTAssertEqual(withoutCount.messages.map(\.id), ["msg-1"])
    }

    // MARK: - Migration

    @MainActor
    func test_migrateFromChatTakesOverKeyAndClearsItInChatModel() async {
        let chat = ChatViewModelTests.makeOlderHistoryViewModel(history: [.mock(id: "msg-2")], olderPage: ChatViewModelTests.olderPage2)
        await chat.viewModel.start()
        let (transcript, spy) = makeOlderHistoryTranscriptModel(olderPage: nil)
        transcript.environment.fetchSiteConfigurations = { try .mock() }
        transcript.environment.shouldShowLeaveSecureConversationDialog = { _ in false }
        transcript.environment.startSocketObservation = {}

        await transcript.migrate(from: chat.viewModel)

        XCTAssertEqual(transcript.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
        XCTAssertNil(chat.viewModel.olderHistoryLoader.olderPage)
    }

    @MainActor
    func test_migrateToChatHandsOverKeyAndClearsItInTranscriptModel() {
        let (transcript, _) = makeOlderHistoryTranscriptModel(olderPage: ChatViewModelTests.olderPage2)
        transcript.historySection.set([chatItem(id: "msg-2")])
        let chat = ChatViewModelTests.makeOlderHistoryViewModel(olderPage: nil)

        chat.viewModel.migrate(from: transcript)

        XCTAssertEqual(chat.viewModel.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertEqual(chat.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
        XCTAssertNil(transcript.olderHistoryLoader.olderPage)
    }

    @MainActor
    func test_migrateToChatDropsOlderPageArrivingInTranscriptModelAfterSwap() async {
        let gate = OlderPageGate()
        let (transcript, spy) = makeOlderHistoryTranscriptModel(
            olderPage: ChatViewModelTests.olderPage2,
            fetchOlderChatHistory: { _ in await gate.wait() }
        )
        transcript.historySection.set([chatItem(id: "msg-2")])
        transcript.event(.loadOlderHistoryRequested)
        await waitUntil { gate.isWaiting }
        let chat = ChatViewModelTests.makeOlderHistoryViewModel(olderPage: nil)
        chat.viewModel.migrate(from: transcript)
        spy.actions.removeAll()

        gate.open(with: .init(messages: [.mock(id: "msg-1")], olderPage: ChatViewModelTests.olderPage3))
        await transcript.olderHistoryLoader.currentLoad?.value

        XCTAssertTrue(spy.actions.isEmpty)
        XCTAssertEqual(chat.viewModel.olderHistoryLoader.olderPage, ChatViewModelTests.olderPage2)
        XCTAssertFalse(chat.viewModel.olderHistoryLoader.isLoading)
    }
}

// MARK: - Helpers

extension SecureConversationsTranscriptModelTests {
    /// Holds an older-page request open until the test releases it.
    @MainActor
    final class OlderPageGate {
        private var continuation: CheckedContinuation<CoreSdkClient.ChatHistoryPage, Never>?
        private(set) var isWaiting = false
        private(set) var isFinished = false

        func wait() async -> CoreSdkClient.ChatHistoryPage {
            let page = await withCheckedContinuation { continuation in
                self.continuation = continuation
                isWaiting = true
            }
            isFinished = true
            return page
        }

        func open(with page: CoreSdkClient.ChatHistoryPage) {
            continuation?.resume(returning: page)
            continuation = nil
        }
    }

    private func chatItem(id: String) -> ChatItem {
        ChatItem(kind: .visitorMessage(.mock(id: id), status: nil))
    }

    /// Requests the next older page and waits until the load finishes.
    @MainActor
    private func loadOlderHistory(_ viewModel: TranscriptModel, spy: ChatViewModelTests.OlderHistoryActionSpy) async {
        let finishedLoads = spy.olderHistoryStates.filter { !$0.isLoading }.count
        viewModel.event(.loadOlderHistoryRequested)
        await waitUntil { spy.olderHistoryStates.filter { !$0.isLoading }.count > finishedLoads }
    }

    @MainActor
    private func loadHistoryInTranscriptModel(
        olderPage: CoreSdkClient.OlderChatHistoryPage?,
        fetchChatHistory: CoreSdkClient.FetchChatHistory? = nil
    ) async -> (model: TranscriptModel, spy: ChatViewModelTests.OlderHistoryActionSpy) {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(olderPage: nil)
        var modelEnv = viewModel.environment
        modelEnv.fetchChatHistory = fetchChatHistory ?? { .init(messages: [.mock(id: "msg-1")], olderPage: olderPage) }
        modelEnv.secureConversations.getUnreadMessageCount = { 0 }
        modelEnv.fetchSiteConfigurations = { try .mock() }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.shouldShowLeaveSecureConversationDialog = { _ in false }
        modelEnv.startSocketObservation = {}
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

        await model.start(isTranscriptFetchNeeded: true)
        return (model, spy)
    }

    private func makeOlderHistoryTranscriptModel(
        olderPage: CoreSdkClient.OlderChatHistoryPage?,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _ in
            XCTFail("Unexpected fetchOlderChatHistory")
            return .init(messages: [])
        }
    ) -> (viewModel: TranscriptModel, spy: ChatViewModelTests.OlderHistoryActionSpy) {
        var modelEnv = TranscriptModel.Environment.failing
        modelEnv.log = .mock
        modelEnv.fileManager = .mock
        modelEnv.createFileUploadListModel = { _ in .mock() }
        modelEnv.getQueues = { [] }
        modelEnv.maximumUploads = { 2 }
        modelEnv.createEntryWidget = { _ in .mock() }
        modelEnv.loadChatMessagesFromHistory = { true }
        modelEnv.fetchOlderChatHistory = fetchOlderChatHistory
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
