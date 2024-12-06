@testable import GliaWidgets
import XCTest

final class SecureConversationsPendingInteractionTests: XCTestCase {
    func test_hasPendingInteractionGetChangedBasedOnUnreadCountAndPendingStatus() throws {
        var environment = SecureConversations.PendingInteraction.Environment.failing
        let uuidGen = UUID.incrementing
        var pendingCallback: ((Result<Bool, Error>) -> Void)?
        environment.observePendingSecureConversationsStatus = { callback in
            pendingCallback = callback
            return uuidGen().uuidString
        }
        var unreadCountCallback: ((Result<Int?, Error>) -> Void)?
        environment.observeSecureConversationsUnreadMessageCount = { callback in
            unreadCountCallback = callback
            return uuidGen().uuidString
        }
        environment.unsubscribeFromPendingStatus = { _ in }
        environment.unsubscribeFromUnreadCount = { _ in }

        let pendingInteraction = SecureConversations.PendingInteraction(environment: environment)
        // Assert initial pending interaction is false.
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        // Affect pending secure conversations value by setting it to `true` and assert `hasPendingInteraction`,
        // then set it back to `false` and assert again.
        try XCTUnwrap(pendingCallback)(.success(true))
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        try XCTUnwrap(pendingCallback)(.success(false))
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        // Affect unread count value by setting it to `1` and assert `hasPendingInteraction`,
        // then set it back to `0` and `nil` and assert again.
        try XCTUnwrap(unreadCountCallback)(.success(1))
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        try XCTUnwrap(unreadCountCallback)(.success(0))
        try XCTUnwrap(unreadCountCallback)(.success(nil))
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
    }

    func test_unsubscribeIsCalledOnDeinit() {
        enum Call {
            case unsubscribeFromPendingStatus
            case unsubscribeFromUnreadCount
        }
        var calls: [Call] = []
        var environment = SecureConversations.PendingInteraction.Environment.failing
        let uuidGen = UUID.incrementing
        environment.observePendingSecureConversationsStatus = { _ in uuidGen().uuidString }
        environment.observeSecureConversationsUnreadMessageCount = { _ in uuidGen().uuidString }
        environment.unsubscribeFromPendingStatus = { _ in
            calls.append(.unsubscribeFromPendingStatus)
        }
        environment.unsubscribeFromUnreadCount = { _ in
            calls.append(.unsubscribeFromUnreadCount)
        }
        var pendingInteraction = SecureConversations.PendingInteraction(environment: environment)
        pendingInteraction = .mock()
        _ = pendingInteraction
        XCTAssertEqual(calls, [.unsubscribeFromUnreadCount, .unsubscribeFromPendingStatus])
    }
}
