@testable import GliaWidgets
@_spi(GliaWidgets) internal import GliaCoreSDK
import XCTest

extension ChatViewModelTests {
    static let olderPage2 = CoreSdkClient.OlderChatHistoryPage(url: "/api/v2/interactions/participants?p=2")
    static let olderPage3 = CoreSdkClient.OlderChatHistoryPage(url: "/api/v2/interactions/participants?p=3")

    @MainActor
    func test_loadHistoryEmitsOlderHistoryAvailability() async {
        let olderAvailable = Self.makeOlderHistoryViewModel(olderPage: Self.olderPage2)
        await olderAvailable.viewModel.start()
        XCTAssertEqual(olderAvailable.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))

        let nothingOlder = Self.makeOlderHistoryViewModel(olderPage: nil)
        await nothingOlder.viewModel.start()
        XCTAssertEqual(nothingOlder.spy.olderHistoryStates.last, .init(canLoad: false, isLoading: false))
    }

    @MainActor
    func test_loadHistoryWithEmptyFirstPageAndKeyAllowsOlderHistory() async {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(history: [], olderPage: Self.olderPage2)

        await viewModel.start()

        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
    }

    @MainActor
    func test_loadHistoryFailureLeavesNoKey() async {
        var viewModelEnv = Self.olderHistoryEnvironment(fetchOlderChatHistory: { _ in
            XCTFail("Unexpected fetchOlderChatHistory")
            return .init(messages: [])
        })
        viewModelEnv.fetchChatHistory = { throw CoreSdkClient.GliaCoreError(reason: "offline") }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        let spy = OlderHistoryActionSpy()
        viewModel.action = { spy.actions.append($0) }

        await viewModel.start()
        viewModel.event(.loadOlderHistoryRequested)
        await Task.yield()

        XCTAssertEqual(spy.olderHistoryStates, [.init(canLoad: false, isLoading: false)])
    }

    @MainActor
    func test_loadOlderHistoryRequestedWhenNothingOlderDoesNotFetch() async {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(olderPage: nil)
        await viewModel.start()
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)
        await Task.yield()

        XCTAssertTrue(spy.actions.isEmpty)
    }

    @MainActor
    func test_loadOlderHistoryRequestedWhileLoadingDoesNotFetchAgain() async {
        var fetchCount = 0
        let gate = SecureConversationsTranscriptModelTests.OlderPageGate()
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _ in
                fetchCount += 1
                return await gate.wait()
            }
        )
        await viewModel.start()

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)
        await waitUntil { fetchCount == 1 }
        await Task.yield()

        XCTAssertEqual(fetchCount, 1)
        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: true))

        gate.open(with: .init(messages: []))
        await viewModel.olderHistoryLoader.currentLoad?.value
    }

    @MainActor
    func test_loadOlderHistoryRequestedPassesKeysFromPreviousPages() async {
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { key in
                requestedKeys.append(key)
                let next = key == Self.olderPage2 ? Self.olderPage3 : nil
                return .init(messages: [.mock(id: "older-\(requestedKeys.count)")], olderPage: next)
            }
        )
        await viewModel.start()

        await loadOlderHistory(viewModel, spy: spy)
        await loadOlderHistory(viewModel, spy: spy)
        viewModel.event(.loadOlderHistoryRequested)
        await Task.yield()

        XCTAssertEqual(requestedKeys, [Self.olderPage2, Self.olderPage3])
    }

    @MainActor
    func test_loadOlderHistoryRequestedPrependsOlderMessagesInOrder() async {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-3")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _ in
                .init(messages: [.mock(id: "msg-1"), .mock(id: "msg-2")], olderPage: nil)
            }
        )
        await viewModel.start()
        spy.actions.removeAll()

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2", "msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: false, isLoading: false)
        ])
        XCTAssertEqual(spy.prependedRows, [.init(count: 2, section: viewModel.historySection.index)])
    }

    @MainActor
    func test_loadOlderHistoryRequestedDropsMessagesAlreadyShown() async {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-2")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _ in
                .init(messages: [.mock(id: "msg-1"), .mock(id: "MSG-2"), .mock(id: "msg-3")])
            }
        )
        await viewModel.start()
        viewModel.interactorEvent(.receivedMessage(.mock(id: "msg-3")))
        spy.actions.removeAll()

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2"])
        XCTAssertEqual(spy.prependedRows, [.init(count: 1, section: viewModel.historySection.index)])
        XCTAssertTrue(viewModel.historyMessageIds.contains("MSG-1"))
    }

    @MainActor
    func test_loadOlderHistoryRequestedFailureStopsLoadingKeepsHistoryAndKey() async {
        var logger = CoreSdkClient.Logger.mock
        var warnings: [String] = []
        logger.warningClosure = { message, _, _, _ in warnings.append("\(message)") }
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-3")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { key in
                requestedKeys.append(key)
                throw CoreSdkClient.GliaCoreError(reason: "offline")
            },
            log: logger
        )
        await viewModel.start()
        spy.actions.removeAll()
        warnings.removeAll()

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: true, isLoading: false)
        ])
        XCTAssertTrue(spy.prependedRows.isEmpty)
        XCTAssertEqual(warnings.count, 1)

        await loadOlderHistory(viewModel, spy: spy)
        XCTAssertEqual(requestedKeys, [Self.olderPage2, Self.olderPage2])
    }

    @MainActor
    func test_loadOlderHistoryRequestedWithOnlyKnownMessagesDoesNotPrepend() async {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-1")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _ in
                .init(messages: [.mock(id: "msg-1")], olderPage: Self.olderPage3)
            }
        )
        await viewModel.start()
        spy.actions.removeAll()

        await loadOlderHistory(viewModel, spy: spy)

        XCTAssertTrue(spy.prependedRows.isEmpty)
        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
    }

    @MainActor
    func test_olderChoiceCardIsInactive() async throws {
        let choiceCard: ChatMessage = .mock(
            id: "card-1",
            sender: .operator,
            attachment: .mock(type: .singleChoice, files: [], imageUrl: nil, options: [try .mock()])
        )
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _ in .init(messages: [choiceCard]) }
        )
        await viewModel.start()

        await loadOlderHistory(viewModel, spy: spy)

        guard case let .choiceCard(_, _, _, isActive) = viewModel.historySection.items.first?.kind else {
            return XCTFail("Expected an older choice card at the top of history")
        }
        XCTAssertFalse(isActive)
    }
}

// MARK: - Helpers

extension ChatViewModelTests {
    final class OlderHistoryActionSpy {
        struct OlderHistoryState: Equatable {
            let canLoad: Bool
            let isLoading: Bool
        }

        struct PrependedRows: Equatable {
            let count: Int
            let section: Int
        }

        var actions: [ChatViewModel.Action] = []

        var olderHistoryStates: [OlderHistoryState] {
            actions.compactMap {
                guard case let .olderHistoryStateUpdated(canLoad, isLoading) = $0 else { return nil }
                return .init(canLoad: canLoad, isLoading: isLoading)
            }
        }

        var prependedRows: [PrependedRows] {
            actions.compactMap {
                guard case let .prependRows(count, section) = $0 else { return nil }
                return .init(count: count, section: section)
            }
        }
    }

    static func olderHistoryEnvironment(
        history: [ChatMessage] = [],
        olderPage: CoreSdkClient.OlderChatHistoryPage? = nil,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory,
        log: CoreSdkClient.Logger = .mock
    ) -> ChatViewModel.Environment {
        var viewModelEnv = ChatViewModel.Environment.failing(
            fetchChatHistory: { .init(messages: history, olderPage: olderPage) },
            fetchOlderChatHistory: fetchOlderChatHistory
        )
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { try .mock() }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        viewModelEnv.log = log
        return viewModelEnv
    }

    static func makeOlderHistoryViewModel(
        history: [ChatMessage] = [],
        olderPage: CoreSdkClient.OlderChatHistoryPage?,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _ in
            XCTFail("Unexpected fetchOlderChatHistory")
            return .init(messages: [])
        },
        log: CoreSdkClient.Logger = .mock
    ) -> (viewModel: ChatViewModel, spy: OlderHistoryActionSpy) {
        let viewModelEnv = olderHistoryEnvironment(
            history: history,
            olderPage: olderPage,
            fetchOlderChatHistory: fetchOlderChatHistory,
            log: log
        )
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        let spy = OlderHistoryActionSpy()
        viewModel.action = { spy.actions.append($0) }
        return (viewModel, spy)
    }

    /// Requests the next older page and waits until the load finishes.
    @MainActor
    func loadOlderHistory(_ viewModel: ChatViewModel, spy: OlderHistoryActionSpy) async {
        let finishedLoads = spy.olderHistoryStates.filter { !$0.isLoading }.count
        viewModel.event(.loadOlderHistoryRequested)
        await waitUntil { spy.olderHistoryStates.filter { !$0.isLoading }.count > finishedLoads }
    }
}
