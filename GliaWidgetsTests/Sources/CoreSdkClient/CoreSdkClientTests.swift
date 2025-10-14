import XCTest
@testable import GliaWidgets

final class CoreSdkClientTests: XCTestCase {
    func testAsyncBridgeResultReturnsSuccessValue() async throws {
        let value: Int = try await CoreSdkClient.AsyncBridge.result { (
            completion: @escaping (Result<Int, NSError>) -> Void
        ) in
            completion(.success(7))
        }

        XCTAssertEqual(value, 7)
    }

    func testAsyncBridgeResultThrowsFailureError() async {
        let expectedError = NSError(domain: "AsyncBridgeResult", code: 1)

        do {
            let _: Int = try await CoreSdkClient.AsyncBridge.result { (
                completion: @escaping (Result<Int, NSError>) -> Void
            ) in
                completion(.failure(expectedError))
            }
            XCTFail("Expected bridge to throw")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }

    func testAsyncBridgeOptionalPairThrowsFallbackErrorForNilValue() async {
        let expectedError = NSError(domain: "AsyncBridgeOptionalPair", code: 1)

        do {
            let _: Int = try await CoreSdkClient.AsyncBridge.optionalPair(
                nilError: expectedError
            ) { (completion: @escaping (Int?, Error?) -> Void) in
                completion(nil, nil)
            }
            XCTFail("Expected bridge to throw fallback error")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }

    func testAsyncBridgeCancellableResultRetainsCancellableUntilCompletion() async throws {
        let completionBox = Boxed<((Result<Int, NSError>) -> Void)?>(value: nil)
        weak var weakCancellable: CoreSdkClient.Cancellable?

        let task = Task {
            try await CoreSdkClient.AsyncBridge.cancellableResult { (
                completion: @escaping (Result<Int, NSError>) -> Void
            ) in
                completionBox.value = completion
                let cancellable = CoreSdkClient.Cancellable()
                weakCancellable = cancellable
                return cancellable
            }
        }

        await waitUntil {
            completionBox.value != nil
        }

        XCTAssertNotNil(weakCancellable)

        completionBox.value?(.success(42))

        let value = try await task.value
        XCTAssertEqual(value, 42)
    }

    func testGetNonTransferredSecureConversationEngagementReturnsEngagement() {
        var client = CoreSdkClient.failing
        let engagement = CoreSdkClient.Engagement.mock(status: .engaged, capabilities: .init(text: false))
        client.getCurrentEngagement = { engagement }

        XCTAssertEqual(engagement, client.getNonTransferredSecureConversationEngagement())
    }

    func testGetNonTransferredSecureConversationEngagementReturnsNil() {
        var client = CoreSdkClient.failing
        let engagement = CoreSdkClient.Engagement.mock(status: .transferring, capabilities: .init(text: true))
        client.getCurrentEngagement = { engagement }

        XCTAssertNil(client.getNonTransferredSecureConversationEngagement())
    }
}
