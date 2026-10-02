@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

extension ChatViewModelTests {
    func test_loadHistoryEmitsOlderHistoryAvailability() {
        let olderAvailable = makeOlderHistoryViewModel(hasOlderChatHistory: { true })
        olderAvailable.viewModel.start()
        XCTAssertEqual(olderAvailable.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))

        let nothingOlder = makeOlderHistoryViewModel(hasOlderChatHistory: { false })
        nothingOlder.viewModel.start()
        XCTAssertEqual(nothingOlder.spy.olderHistoryStates.last, .init(canLoad: false, isLoading: false))
    }

    func test_loadOlderHistoryRequestedWhenNothingOlderDoesNotFetch() {
        let (viewModel, spy) = makeOlderHistoryViewModel(hasOlderChatHistory: { false })
        viewModel.start()
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertTrue(spy.actions.isEmpty)
    }

    func test_loadOlderHistoryRequestedWhileLoadingDoesNotFetchAgain() {
        var fetchCount = 0
        let (viewModel, _) = makeOlderHistoryViewModel(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { _ in fetchCount += 1 }
        )
        viewModel.start()

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(fetchCount, 1)
    }

    func test_loadOlderHistoryRequestedPrependsOlderMessagesInOrder() {
        var hasOlder = true
        let (viewModel, spy) = makeOlderHistoryViewModel(
            history: [.mock(id: "msg-3")],
            hasOlderChatHistory: { hasOlder },
            fetchOlderChatHistory: { completion in
                hasOlder = false
                completion(.success([.mock(id: "msg-1"), .mock(id: "msg-2")]))
            }
        )
        viewModel.start()
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2", "msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: false, isLoading: false)
        ])
        XCTAssertEqual(spy.prependedRows, [.init(count: 2, section: viewModel.historySection.index)])
    }

    func test_loadOlderHistoryRequestedDropsMessagesAlreadyShown() {
        let (viewModel, spy) = makeOlderHistoryViewModel(
            history: [.mock(id: "msg-2")],
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { completion in
                completion(.success([.mock(id: "msg-1"), .mock(id: "MSG-2"), .mock(id: "msg-3")]))
            }
        )
        viewModel.start()
        viewModel.interactorEvent(.receivedMessage(.mock(id: "msg-3")))
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-1", "msg-2"])
        XCTAssertEqual(spy.prependedRows, [.init(count: 1, section: viewModel.historySection.index)])
        XCTAssertTrue(viewModel.historyMessageIds.contains("MSG-1"))
    }

    func test_loadOlderHistoryRequestedFailureStopsLoadingAndKeepsHistory() {
        var logger = CoreSdkClient.Logger.mock
        var warnings: [String] = []
        logger.warningClosure = { message, _, _, _ in warnings.append("\(message)") }
        let (viewModel, spy) = makeOlderHistoryViewModel(
            history: [.mock(id: "msg-3")],
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { $0(.failure(CoreSdkClient.GliaCoreError(reason: "offline"))) },
            log: logger
        )
        viewModel.start()
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(viewModel.historySection.items.compactMap(\.chatMessage?.id), ["msg-3"])
        XCTAssertEqual(spy.olderHistoryStates, [
            .init(canLoad: true, isLoading: true),
            .init(canLoad: true, isLoading: false)
        ])
        XCTAssertTrue(spy.prependedRows.isEmpty)
        XCTAssertEqual(warnings.count, 1)
    }

    func test_loadOlderHistoryRequestedWithOnlyKnownMessagesDoesNotPrepend() {
        let (viewModel, spy) = makeOlderHistoryViewModel(
            history: [.mock(id: "msg-1")],
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { $0(.success([.mock(id: "msg-1")])) }
        )
        viewModel.start()
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertTrue(spy.prependedRows.isEmpty)
        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
    }

    func test_olderChoiceCardIsInactive() throws {
        let choiceCard: ChatMessage = .mock(
            id: "card-1",
            sender: .operator,
            attachment: .mock(type: .singleChoice, files: [], imageUrl: nil, options: [try .mock()])
        )
        let (viewModel, _) = makeOlderHistoryViewModel(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { $0(.success([choiceCard])) }
        )
        viewModel.start()

        viewModel.event(.loadOlderHistoryRequested)

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

    private func makeOlderHistoryViewModel(
        history: [ChatMessage] = [],
        hasOlderChatHistory: @escaping CoreSdkClient.HasOlderChatHistory,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _ in
            XCTFail("Unexpected fetchOlderChatHistory")
        },
        log: CoreSdkClient.Logger = .mock
    ) -> (viewModel: ChatViewModel, spy: OlderHistoryActionSpy) {
        var viewModelEnv = ChatViewModel.Environment.failing(
            fetchChatHistory: { $0(.success(history)) },
            fetchOlderChatHistory: fetchOlderChatHistory,
            hasOlderChatHistory: hasOlderChatHistory
        )
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        viewModelEnv.log = log
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        let spy = OlderHistoryActionSpy()
        viewModel.action = { spy.actions.append($0) }
        return (viewModel, spy)
    }
}
