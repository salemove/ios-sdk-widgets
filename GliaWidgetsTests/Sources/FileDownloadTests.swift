import Foundation
@testable import GliaWidgets
import XCTest

class FileDownloadTests: XCTestCase {
    typealias FetchFile = FileDownload.Environment.FetchFile

    @MainActor
    func test_repeatedStartDoesNotDownloadAnInFlightOrCompletedFileAgain() async {
        let started = expectation(description: "Download started")
        var continuation: CheckedContinuation<CoreSdkClient.EngagementFileData, Never>?
        var requests = 0
        var environment = FileDownload.Environment.mock
        environment.fetchFile = { _, _ in
            requests += 1
            if requests > 1 { return .mock() }
            return await withCheckedContinuation {
                continuation = $0
                started.fulfill()
            }
        }
        let download = FileDownload.mock(
            file: .mock(id: "file", url: URL(string: "https://example.test/file"), name: "file"),
            environment: environment
        )
        let task = Task { await download.startDownload() }
        await fulfillment(of: [started], timeout: 1)

        await download.startDownload()
        XCTAssertEqual(requests, 1)
        continuation?.resume(returning: .mock())
        await task.value
        await download.startDownload()
        XCTAssertEqual(requests, 1)
    }

    @MainActor
    func test_autoDownloadStartsAllImagesWithoutWaitingForTheFirst() async {
        let started = expectation(description: "Both images started")
        started.expectedFulfillmentCount = 2
        var continuations: [CheckedContinuation<CoreSdkClient.EngagementFileData, Never>] = []
        var environment = FileDownloader.Environment.create(with: ChatViewModel.Environment.mock)
        environment.createFileDownload = FileDownload.init(with:storage:environment:)
        environment.fetchFile = { _, _ in
            await withCheckedContinuation {
                continuations.append($0)
                started.fulfill()
            }
        }
        let downloader = FileDownloader(environment: environment)
        let files = ["first", "second"].map {
            ChatEngagementFile(
                id: $0, url: URL(string: "https://example.test/\($0).png"),
                name: "\($0).png", size: 1, contentType: "image/png", isDeleted: false
            )
        }
        _ = downloader.downloads(for: files, autoDownload: .images)

        await fulfillment(of: [started], timeout: 1)
        for continuation in continuations {
            continuation.resume(returning: .mock())
        }
    }

    func testFetchForEngagementFileChoosesRespectiveEndpoint() throws {
        let mockId = UUID.mock.uuidString
        let engagementFileUrl = try XCTUnwrap(
            URL(string: "https://mock.mock.mock.moc/engagements/\(mockId)/files/\(mockId)")
        )
        let secureMessagingFileUrl = try XCTUnwrap(
            URL(string: "https://mock.mock.mock.moc/messaging/files/\(mockId)")
        )

        let generalFileUrl = try XCTUnwrap(
            URL(string: "https://mock.mock.mock.moc")
        )

        enum Fetch: Equatable {
            case engagement
            case secureMessaging
        }

        let env = FetchFile.Environment(
            fetchFile: { _, _ in .mock() },
            downloadSecureFile: { _, _ in .mock() }
        )

        func evaluateFile(_ file: CoreSdkClient.EngagementFile) -> Fetch {
            switch FetchFile.fetchForEngagementFile(file, environment: env) {
            case .fromEngagement:
                return .engagement
            case .fromSecureMessaging:
                return .secureMessaging
            }
        }

        XCTAssertEqual(evaluateFile(.init(url: engagementFileUrl)), .engagement)
        XCTAssertEqual(evaluateFile(.init(url: secureMessagingFileUrl)), .secureMessaging)
        XCTAssertEqual(evaluateFile(.init(url: generalFileUrl)), .engagement)
    }

    func testAccessibilityStrings() {
        let strings = [
            "download",
            "downloading",
            "downloaded",
            "error"
        ]

        let states: [FileDownload.State] = [
            .none,
            .downloading(progress: .init(with: 0)),
            .downloaded(.mock()),
            .error(.network)
        ]

        XCTAssertEqual(states.map(\.accessibilityString), strings)
    }
}
