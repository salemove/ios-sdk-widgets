@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

extension ChatViewModelTests {
    static let olderPage2 = CoreSdkClient.OlderChatHistoryPage(url: "/api/v2/interactions/participants?p=2")
    static let olderPage3 = CoreSdkClient.OlderChatHistoryPage(url: "/api/v2/interactions/participants?p=3")

    func test_loadHistoryEmitsOlderHistoryAvailability() {
        let olderAvailable = Self.makeOlderHistoryViewModel(olderPage: Self.olderPage2)
        olderAvailable.viewModel.start()
        XCTAssertEqual(olderAvailable.spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))

        let nothingOlder = Self.makeOlderHistoryViewModel(olderPage: nil)
        nothingOlder.viewModel.start()
        XCTAssertEqual(nothingOlder.spy.olderHistoryStates.last, .init(canLoad: false, isLoading: false))
    }

    func test_loadHistoryWithEmptyFirstPageAndKeyAllowsOlderHistory() {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(history: [], olderPage: Self.olderPage2)

        viewModel.start()

        XCTAssertEqual(spy.olderHistoryStates.last, .init(canLoad: true, isLoading: false))
    }

    func test_loadHistoryFailureLeavesNoKey() {
        var viewModelEnv = Self.olderHistoryEnvironment(fetchOlderChatHistory: { _, _ in
            XCTFail("Unexpected fetchOlderChatHistory")
        })
        viewModelEnv.fetchChatHistory = { $0(.failure(CoreSdkClient.GliaCoreError(reason: "offline"))) }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        let spy = OlderHistoryActionSpy()
        viewModel.action = { spy.actions.append($0) }

        viewModel.start()
        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(spy.olderHistoryStates, [.init(canLoad: false, isLoading: false)])
    }

    func test_loadOlderHistoryRequestedWhenNothingOlderDoesNotFetch() {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(olderPage: nil)
        viewModel.start()
        spy.actions.removeAll()

        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertTrue(spy.actions.isEmpty)
    }

    func test_loadOlderHistoryRequestedWhileLoadingDoesNotFetchAgain() {
        var fetchCount = 0
        let (viewModel, _) = Self.makeOlderHistoryViewModel(
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _, _ in fetchCount += 1 }
        )
        viewModel.start()

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(fetchCount, 1)
    }

    func test_loadOlderHistoryRequestedPassesKeysFromPreviousPages() {
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let (viewModel, _) = Self.makeOlderHistoryViewModel(
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { key, completion in
                requestedKeys.append(key)
                let next = key == Self.olderPage2 ? Self.olderPage3 : nil
                completion(.success(.init(messages: [.mock(id: "older-\(requestedKeys.count)")], olderPage: next)))
            }
        )
        viewModel.start()

        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)
        viewModel.event(.loadOlderHistoryRequested)

        XCTAssertEqual(requestedKeys, [Self.olderPage2, Self.olderPage3])
    }

    func test_loadOlderHistoryRequestedPrependsOlderMessagesInOrder() {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-3")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _, completion in
                completion(.success(.init(messages: [.mock(id: "msg-1"), .mock(id: "msg-2")], olderPage: nil)))
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
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-2")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _, completion in
                completion(.success(.init(messages: [.mock(id: "msg-1"), .mock(id: "MSG-2"), .mock(id: "msg-3")])))
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

    func test_loadOlderHistoryRequestedFailureStopsLoadingKeepsHistoryAndKey() {
        var logger = CoreSdkClient.Logger.mock
        var warnings: [String] = []
        logger.warningClosure = { message, _, _, _ in warnings.append("\(message)") }
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-3")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { key, completion in
                requestedKeys.append(key)
                completion(.failure(CoreSdkClient.GliaCoreError(reason: "offline")))
            },
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

        viewModel.event(.loadOlderHistoryRequested)
        XCTAssertEqual(requestedKeys, [Self.olderPage2, Self.olderPage2])
    }

    func test_loadOlderHistoryRequestedWithOnlyKnownMessagesDoesNotPrepend() {
        let (viewModel, spy) = Self.makeOlderHistoryViewModel(
            history: [.mock(id: "msg-1")],
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _, completion in
                completion(.success(.init(messages: [.mock(id: "msg-1")], olderPage: Self.olderPage3)))
            }
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
        let (viewModel, _) = Self.makeOlderHistoryViewModel(
            olderPage: Self.olderPage2,
            fetchOlderChatHistory: { _, completion in completion(.success(.init(messages: [choiceCard]))) }
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

    static func olderHistoryEnvironment(
        history: [ChatMessage] = [],
        olderPage: CoreSdkClient.OlderChatHistoryPage? = nil,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory,
        log: CoreSdkClient.Logger = .mock
    ) -> ChatViewModel.Environment {
        var viewModelEnv = ChatViewModel.Environment.failing(
            fetchChatHistory: { $0(.success(.init(messages: history, olderPage: olderPage))) },
            fetchOlderChatHistory: fetchOlderChatHistory
        )
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        viewModelEnv.log = log
        return viewModelEnv
    }

    static func makeOlderHistoryViewModel(
        history: [ChatMessage] = [],
        olderPage: CoreSdkClient.OlderChatHistoryPage?,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _, _ in
            XCTFail("Unexpected fetchOlderChatHistory")
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
}
