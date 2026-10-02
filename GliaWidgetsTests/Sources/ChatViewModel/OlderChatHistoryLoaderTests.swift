@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

final class OlderChatHistoryLoaderTests: XCTestCase {
    func test_canLoadDelegatesToHasOlderChatHistory() {
        var hasOlder = true
        let loader = makeLoader(hasOlderChatHistory: { hasOlder })

        XCTAssertTrue(loader.canLoad)
        hasOlder = false
        XCTAssertFalse(loader.canLoad)
    }

    func test_loadWhenNothingOlderDoesNotFetch() {
        let loader = makeLoader(hasOlderChatHistory: { false })
        var completions = 0

        loader.load { _ in completions += 1 }

        XCTAssertEqual(completions, 0)
    }

    func test_loadKeepsOneRequestInFlight() {
        var pendingCompletions: [(Result<[ChatMessage], CoreSdkClient.GliaCoreError>) -> Void] = []
        let loader = makeLoader(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { pendingCompletions.append($0) }
        )
        var results: [[ChatMessage]?] = []

        loader.load { results.append($0) }
        XCTAssertTrue(loader.isLoading)
        XCTAssertFalse(loader.canStartLoading)
        loader.load { results.append($0) }
        XCTAssertEqual(pendingCompletions.count, 1)

        pendingCompletions.first?(.success([.mock(id: "msg-1")]))

        XCTAssertFalse(loader.isLoading)
        XCTAssertEqual(results.map { $0?.map(\.id) }, [["msg-1"]])
    }

    func test_loadFailureCompletesWithNilAndLogsWarning() {
        var logger = CoreSdkClient.Logger.mock
        var warnings = 0
        logger.warningClosure = { _, _, _, _ in warnings += 1 }
        let loader = makeLoader(
            hasOlderChatHistory: { true },
            fetchOlderChatHistory: { $0(.failure(CoreSdkClient.GliaCoreError(reason: "offline"))) },
            log: logger
        )
        var results: [[ChatMessage]?] = []

        loader.load { results.append($0) }

        XCTAssertEqual(results.count, 1)
        XCTAssertNil(results.first ?? [])
        XCTAssertEqual(warnings, 1)
        XCTAssertFalse(loader.isLoading)
    }

    private func makeLoader(
        hasOlderChatHistory: @escaping CoreSdkClient.HasOlderChatHistory,
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _ in
            XCTFail("Unexpected fetchOlderChatHistory")
        },
        log: CoreSdkClient.Logger = .mock
    ) -> OlderChatHistoryLoader {
        OlderChatHistoryLoader(
            environment: .init(
                fetchOlderChatHistory: fetchOlderChatHistory,
                hasOlderChatHistory: hasOlderChatHistory,
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
