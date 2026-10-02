@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

extension SecureConversationsTranscriptModelTests {
    func test_olderHistoryRequestedWhenNothingOlderDoesNotFetch() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(hasOlderChatHistory: { false })

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertTrue(spy.actions.isEmpty)
    }

    func test_olderHistoryRequestedWhileLoadingDoesNotFetchAgain() {
        var fetchCount = 0
        let (viewModel, _) = makeOlderHistoryTranscriptModel(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { _ in fetchCount += 1 }
        )

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(fetchCount, 1)
    }

    func test_olderHistoryRequestedPrependsOlderMessagesInOrder() {
        var hasOlder = true
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            hasOlderChatHistory: { hasOlder },
            fetchOlderChatHistory: { completion in
                hasOlder = false
                completion(.success([.mock(id: "msg-1"), .mock(id: "msg-2")]))
            }
        )
        viewModel.historySection.set([chatItem(id: "msg-3")])

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2", "msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: false, isLoading: false)
        ])
        XCTAssertEqual(spy.prependedRows, [.init(count: 2, section: viewModel.historySection.index)])
    }

    func test_olderHistoryRequestedDropsMessagesAlreadyShown() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { $0(.success([.mock(id: "msg-1"), .mock(id: "MSG-2")])) }
        )
        viewModel.historySection.set([chatItem(id: "msg-2"), ChatItem(kind: .unreadMessageDivider)])

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2"])
        XCTAssertEqual(spy.prependedRows, [.init(count: 1, section: viewModel.historySection.index)])
    }

    func test_olderHistoryRequestedFailureStopsLoadingAndKeepsHistory() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { $0(.failure(CoreSdkClient.GliaCoreError(reason: "offline"))) }
        )
        viewModel.historySection.set([chatItem(id: "msg-3")])

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: true, isLoading: false)
        ])
        XCTAssertTrue(spy.prependedRows.isEmpty)
    }

    func test_loadHistoryEmitsOlderHistoryAvailability() {
        let (viewModel, spy) = makeOlderHistoryTranscriptModel(hasOlderChatHistory: { true })
        var modelEnv = viewModel.environment
        modelEnv.fetchChatHistory = { $0(.success([.mock(id: "msg-1")])) }
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

        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
    }
}

// MARK: - Helpers

extension SecureConversationsTranscriptModelTests {
    private func chatItem(id: String) -> ChatItem {
        ChatItem(kind: .visitorMessage(.mock(id: id), status: nil))
    }

    private func makeOlderHistoryTranscriptModel(
        hasOlderChatHistory: @escaping CoreSdkClient.HasOlderChatHistory,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _ in
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
        modelEnv.hasOlderChatHistory = hasOlderChatHistory
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
        let spy = ChatViewModelTests.OlderHistoryActionSpy()
        viewModel.action = { spy.actions.append($0) }
        return (viewModel, spy)
    }
}
