@testable import TestingApp
import XCTest

final class DeeplinkServiceTests: XCTestCase {
    func test_openSettingsUrl() throws {
        let service = DeeplinksService(
            window: nil,
            handlers: [.widgets: DeeplinkHandlerMock.self]
        )
        let url = try XCTUnwrap(URL(string: "glia://widgets/settings"))
        let result = service.openUrl(url, withOptions: [:])
        XCTAssertTrue(result)
    }

    func test_openConfigurationUrl() throws {
        let service = DeeplinksService(
            window: nil,
            handlers: [.configure: DeeplinkHandlerMock.self]
        )
        let url = try XCTUnwrap(URL(string: "glia://configure?mock=mock"))
        let result = service.openUrl(url, withOptions: [:])
        XCTAssertTrue(result)
    }

    func test_openUnsupportedUrl() throws {
        let service = DeeplinksService(
            window: nil,
            handlers: [
                .widgets: DeeplinkHandlerMock.self,
                .configure: DeeplinkHandlerMock.self
            ]
        )
        let url = try XCTUnwrap(URL(string: "glia://mock?mock=mock"))
        let result = service.openUrl(url, withOptions: [:])
        XCTAssertFalse(result)
    }
}
