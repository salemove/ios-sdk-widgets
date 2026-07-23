@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import Combine
import XCTest

final class SecureConversationsPendingInteractionTests: XCTestCase {
    func test_hasPendingInteractionGetChanged() async throws {
        var environment = SecureConversations.PendingInteraction.Environment.failing
        var pendingContinuation: AsyncThrowingStream<Bool, Swift.Error>.Continuation?
        let pendingStream = AsyncThrowingStream<Bool, Swift.Error> { continuation in
            pendingContinuation = continuation
        }
        var unreadCountContinuation: AsyncThrowingStream<Int?, Swift.Error>.Continuation?
        let unreadCountStream = AsyncThrowingStream<Int?, Swift.Error> { continuation in
            unreadCountContinuation = continuation
        }
        let interactor = Interactor.mock()
        interactor.state = .none
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()
        environment.observePendingSecureConversationsStatus = { pendingStream }
        environment.observeSecureConversationsUnreadMessageCount = { unreadCountStream }

        let pendingInteraction = try SecureConversations.PendingInteraction(environment: environment)
        // Assert initial pending interaction is false.
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        // Affect pending secure conversations value by setting it to `true` and assert `hasPendingInteraction`,
        // then set it back to `false` and assert again.
        try XCTUnwrap(pendingContinuation).yield(true)
        await waitUntil { pendingInteraction.hasPendingInteraction }
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        try XCTUnwrap(pendingContinuation).yield(false)
        await waitUntil { !pendingInteraction.hasPendingInteraction }
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        // Affect unread count value by setting it to `1` and assert `hasPendingInteraction`,
        // then set it back to `0` and `nil` and assert again.
        try XCTUnwrap(unreadCountContinuation).yield(1)
        await waitUntil { pendingInteraction.hasPendingInteraction }
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        try XCTUnwrap(unreadCountContinuation).yield(0)
        await waitUntil { !pendingInteraction.hasPendingInteraction }
        try XCTUnwrap(unreadCountContinuation).yield(nil)
        await waitUntil { !pendingInteraction.hasPendingInteraction }
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        // Affect hasTransferredSC value by setting current engagement and assert `hasPendingInteraction`,
        // then set it back to `nil` and assert again.
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        interactor.setCurrentEngagement(nil)
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)

        // Check if setting current engagement not to SC engagement changes `hasPendingInteraction` to `false`
        try XCTUnwrap(pendingContinuation).yield(true)
        await waitUntil { pendingInteraction.hasPendingInteraction }
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)
        interactor.setCurrentEngagement(.mock(engagedOperator: .mock(), status: .engaged))
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        interactor.setCurrentEngagement(nil)
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)

        // Check if setting `interactor`'s enqueueingEngagementKind to NOT nil changes `hasPendingInteraction` to `false`
        interactor.state = .enqueueing(.audioCall)
        XCTAssertFalse(pendingInteraction.hasPendingInteraction)
        interactor.state = .none
        XCTAssertTrue(pendingInteraction.hasPendingInteraction)

        try XCTUnwrap(pendingContinuation).finish()
        try XCTUnwrap(unreadCountContinuation).finish()
    }

    func test_observationsAreCancelledOnDeinit() async throws {
        let pendingObservationStarted = expectation(description: "Pending status observation started")
        let unreadCountObservationStarted = expectation(description: "Unread count observation started")
        let pendingObservationCancelled = expectation(description: "Pending status observation cancelled")
        let unreadCountObservationCancelled = expectation(description: "Unread count observation cancelled")
        let pendingStream = AsyncThrowingStream<Bool, Swift.Error> { continuation in
            continuation.onTermination = { termination in
                guard case .cancelled = termination else { return }
                pendingObservationCancelled.fulfill()
            }
        }
        let unreadCountStream = AsyncThrowingStream<Int?, Swift.Error> { continuation in
            continuation.onTermination = { termination in
                guard case .cancelled = termination else { return }
                unreadCountObservationCancelled.fulfill()
            }
        }
        var environment = SecureConversations.PendingInteraction.Environment.failing
        environment.observePendingSecureConversationsStatus = {
            pendingObservationStarted.fulfill()
            return pendingStream
        }
        environment.observeSecureConversationsUnreadMessageCount = {
            unreadCountObservationStarted.fulfill()
            return unreadCountStream
        }
        environment.interactorPublisher = .mock(.mock())
        var pendingInteraction: SecureConversations.PendingInteraction? = try .init(environment: environment)
        weak var weakPendingInteraction = pendingInteraction

        await fulfillment(
            of: [pendingObservationStarted, unreadCountObservationStarted],
            timeout: 1
        )
        pendingInteraction = nil

        await fulfillment(
            of: [pendingObservationCancelled, unreadCountObservationCancelled],
            timeout: 1
        )
        XCTAssertNil(weakPendingInteraction)
    }
}
