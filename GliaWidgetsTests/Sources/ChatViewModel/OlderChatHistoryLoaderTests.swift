@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

final class OlderChatHistoryLoaderTests: XCTestCase {
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

    @MainActor
    func test_loadWithoutKeyDoesNotFetch() async {
        let loader = makeLoader()

        let outcome = await loader.load()

        XCTAssertNil(outcome)
    }

    @MainActor
    func test_loadPassesStoredKeyAndStoresNextOne() async {
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let page3 = page3
        let loader = makeLoader(fetchOlderChatHistory: { key in
            requestedKeys.append(key)
            return .init(messages: [.mock(id: "msg-1")], olderPage: requestedKeys.count == 1 ? page3 : nil)
        })
        loader.replaceOlderPage(page2)

        let first = await loader.load()
        XCTAssertEqual(loader.olderPage, page3)
        let second = await loader.load()

        XCTAssertEqual(requestedKeys, [page2, page3])
        XCTAssertNil(loader.olderPage)
        XCTAssertFalse(loader.canLoad)
        XCTAssertEqual(loadedIds(first), ["msg-1"])
        XCTAssertEqual(loadedIds(second), ["msg-1"])
    }

    @MainActor
    func test_loadKeepsOneRequestInFlight() async {
        let gate = SecureConversationsTranscriptModelTests.OlderPageGate()
        var fetchCount = 0
        let loader = makeLoader(fetchOlderChatHistory: { _ in
            fetchCount += 1
            return await gate.wait()
        })
        loader.replaceOlderPage(page2)

        let firstLoad = Task { await loader.load() }
        await waitUntil { gate.isWaiting }
        XCTAssertTrue(loader.isLoading)
        XCTAssertFalse(loader.canStartLoading)
        let second = await loader.load()
        XCTAssertNil(second)
        XCTAssertEqual(fetchCount, 1)

        gate.open(with: .init(messages: [.mock(id: "msg-1")]))
        let first = await firstLoad.value

        XCTAssertFalse(loader.isLoading)
        XCTAssertEqual(loadedIds(first), ["msg-1"])
    }

    @MainActor
    func test_loadFailureKeepsKeyReportsFailureAndLogsWarning() async {
        var logger = CoreSdkClient.Logger.mock
        var warnings = 0
        logger.warningClosure = { _, _, _, _ in warnings += 1 }
        var requestedKeys: [CoreSdkClient.OlderChatHistoryPage] = []
        let loader = makeLoader(
            fetchOlderChatHistory: { key in
                requestedKeys.append(key)
                throw CoreSdkClient.GliaCoreError(reason: "offline")
            },
            log: logger
        )
        loader.replaceOlderPage(page2)

        let first = await loader.load()
        let second = await loader.load()

        XCTAssertTrue(isFailed(first))
        XCTAssertTrue(isFailed(second))
        XCTAssertEqual(warnings, 2)
        XCTAssertFalse(loader.isLoading)
        XCTAssertEqual(loader.olderPage, page2)
        XCTAssertEqual(requestedKeys, [page2, page2])
    }

    @MainActor
    func test_replaceOlderPageDuringLoadDropsResultAndKeepsNewKey() async {
        let gate = SecureConversationsTranscriptModelTests.OlderPageGate()
        let loader = makeLoader(fetchOlderChatHistory: { _ in await gate.wait() })
        loader.replaceOlderPage(page2)

        let load = Task { await loader.load() }
        await waitUntil { gate.isWaiting }
        loader.replaceOlderPage(page3)
        gate.open(with: .init(messages: [.mock(id: "msg-1")], olderPage: nil))
        let outcome = await load.value

        guard case .superseded = outcome else {
            return XCTFail("Expected the in-flight result to be dropped, got \(String(describing: outcome))")
        }
        XCTAssertEqual(loader.olderPage, page3)
        XCTAssertFalse(loader.isLoading)
    }

    private func loadedIds(_ outcome: OlderChatHistoryLoader.LoadOutcome?) -> [String]? {
        guard case let .loaded(messages) = outcome else { return nil }
        return messages.map(\.id)
    }

    private func isFailed(_ outcome: OlderChatHistoryLoader.LoadOutcome?) -> Bool {
        guard case .failed = outcome else { return false }
        return true
    }

    private func makeLoader(
        fetchOlderChatHistory: @escaping CoreSdkClient.FetchOlderChatHistory = { _ in
            XCTFail("Unexpected fetchOlderChatHistory")
            return .init(messages: [])
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
