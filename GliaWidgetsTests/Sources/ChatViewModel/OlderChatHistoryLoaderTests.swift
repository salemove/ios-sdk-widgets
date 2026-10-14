@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

final class OlderChatHistoryLoaderTests: XCTestCase {
    private typealias Completion = (Result<CoreSdkClient.ChatHistoryPage, CoreSdkClient.GliaCoreError>) -> Void

    private let page2 = CoreSdkClient.OlderChatHistoryPage(url: "/api/v2/interactions/participants?p=2")
    private let page3 = CoreSdkClient.OlderChatHistoryPage(url: "/api/v2/interactions/participants?p=3")

    func test_canLoadReflectsStoredKey() {
        let loader = makeLoader()
        XCTAssertFalse(loader.canLoad)

        loader.replaceOlderPage(page2)
        XCTAssertTrue(loader.canLoad)

        loader.replaceOlderPage(nil)
        XCTAssertFalse(loader.canLoad)
    }

    func test_loadWithoutKeyDoesNotFetch() {
        let loader = makeLoader()
        var completions = 0

        loader.load { _ in completions += 1 }

        XCTAssertEqual(completions, 0)
    }

    func test_loadPassesStoredKeyAndStoresNextOne() {
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let page3 = page3
        let loader = makeLoader(fetchOlderChatHistory: { key, completion in
            requestedKeys.append(key)
            completion(.success(.init(messages: [.mock(id: "msg-1")], olderPage: requestedKeys.count == 1 ? page3 : nil)))
        })
        loader.replaceOlderPage(page2)
        var results: [[ChatMessage]?] = []

        loader.load { results.append($0) }
        XCTAssertEqual(loader.olderPage, page3)
        loader.load { results.append($0) }

        XCTAssertEqual(requestedKeys, [page2, page3])
        XCTAssertNil(loader.olderPage)
        XCTAssertFalse(loader.canLoad)
        XCTAssertEqual(results.map { $0?.map(\.id) }, [["msg-1"], ["msg-1"]])
    }

    func test_loadKeepsOneRequestInFlight() {
        var pendingCompletions: [Completion] = []
        let loader = makeLoader(fetchOlderChatHistory: { _, completion in pendingCompletions.append(completion) })
        loader.replaceOlderPage(page2)
        var results: [[ChatMessage]?] = []

        loader.load { results.append($0) }
        XCTAssertTrue(loader.isLoading)
        XCTAssertFalse(loader.canStartLoading)
        loader.load { results.append($0) }
        XCTAssertEqual(pendingCompletions.count, 1)

        pendingCompletions.first?(.success(.init(messages: [.mock(id: "msg-1")])))

        XCTAssertFalse(loader.isLoading)
        XCTAssertEqual(results.map { $0?.map(\.id) }, [["msg-1"]])
    }

    func test_loadFailureKeepsKeyCompletesWithNilAndLogsWarning() {
        var logger = CoreSdkClient.Logger.mock
        var warnings = 0
        logger.warningClosure = { _, _, _, _ in warnings += 1 }
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let loader = makeLoader(
            fetchOlderChatHistory: { key, completion in
                requestedKeys.append(key)
                completion(.failure(CoreSdkClient.GliaCoreError(reason: "offline")))
            },
            log: logger
        )
        loader.replaceOlderPage(page2)
        var results: [[ChatMessage]?] = []

        loader.load { results.append($0) }
        loader.load { results.append($0) }

        XCTAssertEqual(results.count, 2)
        XCTAssertNil(results.first ?? [])
        XCTAssertEqual(warnings, 2)
        XCTAssertFalse(loader.isLoading)
        XCTAssertEqual(loader.olderPage, page2)
        XCTAssertEqual(requestedKeys, [page2, page2])
    }

    func test_replaceOlderPageDuringLoadDropsResultAndKeepsNewKey() {
        var pendingCompletions: [Completion] = []
        let loader = makeLoader(fetchOlderChatHistory: { _, completion in pendingCompletions.append(completion) })
        loader.replaceOlderPage(page2)
        var completions = 0

        loader.load { _ in completions += 1 }
        loader.replaceOlderPage(page3)
        pendingCompletions.first?(.success(.init(messages: [.mock(id: "msg-1")], olderPage: nil)))

        XCTAssertEqual(completions, 0)
        XCTAssertEqual(loader.olderPage, page3)
        XCTAssertFalse(loader.isLoading)
    }

    private func makeLoader(
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _, _ in
            XCTFail("Unexpected fetchOlderChatHistory")
        },
        log: CoreSdkClient.Logger = .mock
    ) -> OlderChatHistoryLoader {
        OlderChatHistoryLoader(
            environment: .init(
                fetchOlderChatHistory: fetchOlderChatHistory,
                log: log
            )
        )
    }
}

final class SectionTests: XCTestCase {
    func test_prependInsertsItemsBeforeExistingOnesInOrder() {
        let section = Section<String>(0)
        section.set(["c"])

        section.prepend(["a", "b"])

        XCTAssertEqual(section.items, ["a", "b", "c"])
    }
}
