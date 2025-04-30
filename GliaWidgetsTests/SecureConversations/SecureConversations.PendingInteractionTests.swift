@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import Combine
import XCTest
@_spi(GliaWidgets) import GliaCoreSDK

final class SecureConversationsPendingInteractionTests: XCTestCase {
    func test_hasPendingInteractionGetChanged() throws {
        var environment = SecureConversations.PendingInteraction.Environment.failing
        let uuidGen = UUID.incrementing
        var pendingCallback: ((Result<Bool, Error>) -> Void)?
        let interactor = Interactor.mock()
        interactor.state = .none
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()
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


        let pendingInteraction = try SecureConversations.PendingInteraction(environment: environment)
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
        // Affect hasTransferredSC value by setting current engagement and assert `hasPendingInteraction`,
        // then set it back to `nil` and assert again.
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        interactor.setCurrentEngagement(nil)
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        
        // Check if setting current engagement not to SC engagement changes `hasPendingInteraction` to `false`
        try XCTUnwrap(pendingCallback)(.success(true))
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        interactor.setCurrentEngagement(.mock(engagedOperator: .mock(), status: .engaged))
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        interactor.setCurrentEngagement(nil)
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        
        // Check if setting `interactor`'s enqueueingEngagementKind to NOT nil changes `hasPendingInteraction` to `false`
        try XCTUnwrap(pendingCallback)(.success(true))
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        interactor.state = .enqueueing(.audioCall)
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        interactor.state = .none
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
    }

    func test_unsubscribeIsCalledOnDeinit() throws {
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
        environment.interactorPublisher = .mock(.mock())
        var pendingInteraction = try SecureConversations.PendingInteraction(environment: environment)
        pendingInteraction = try .mock()
        _ = pendingInteraction
        XCTAssertEqual(calls, [.unsubscribeFromUnreadCount, .unsubscribeFromPendingStatus])
    }
}
