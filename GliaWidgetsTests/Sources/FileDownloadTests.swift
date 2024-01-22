import Foundation
@testable import GliaWidgets
import XCTest

class FileDownloadTests: XCTestCase {
    typealias FetchFile = FileDownload.Environment.FetchFile

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
            fetchFile: { _, _, _ in },
            downloadSecureFile: { _, _, _ in .mock }
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
            "none",
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
