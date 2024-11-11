import XCTest
import Combine
import GliaCoreSDK

@testable import GliaWidgets

class EntryWidgetTests: XCTestCase {
    private enum Call {
        case observeSecureUnreadMessageCount
    }

    func test_secureMessagingIsHiddenWhenUserIsNotAuthenticated() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)

        let engagementLauncher = EngagementLauncher { _, _ in }
        let isAuthenticated: () -> Bool = { false }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            environment: .init(
                observeSecureUnreadMessageCount: { _ in UUID.mock.uuidString },
                unsubscribeFromUpdates: { _, _ in },
                queuesMonitor: queuesMonitor,
                engagementLauncher: engagementLauncher,
                theme: .mock(),
                log: .mock,
                isAuthenticated: isAuthenticated
            )
        )

        entryWidget.show(in: .init())

        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertFalse(mediaTypes.contains(.init(type: .secureMessaging)))
        } else {
            XCTFail("Unexpected view state \(entryWidget.viewState)")
        }
    }

    func test_secureMessagingIsShownWhenUserIsAuthenticated() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let engagementLauncher = EngagementLauncher { _, _ in }
        let isAuthenticated: () -> Bool = { true }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            environment: .init(
                observeSecureUnreadMessageCount: { _ in UUID.mock.uuidString },
                unsubscribeFromUpdates: { _, _ in },
                queuesMonitor: queuesMonitor,
                engagementLauncher: engagementLauncher,
                theme: .mock(),
                log: .mock,
                isAuthenticated: isAuthenticated
            )
        )

        entryWidget.show(in: .init())

        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertTrue(mediaTypes.contains(.init(type: .secureMessaging)))
        } else {
            XCTFail("Unexpected view state \(entryWidget.viewState)")
        }
    }
    
    func test__secureMessagingIsShownWhenUserIsAuthenticatedAndHasUnreadMessages() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)

        let engagementLauncher = EngagementLauncher { _, _ in }
        let isAuthenticated: () -> Bool = { true }
        
        let observeMessageCount: (_ completion: @escaping (Result<Int?, Error>) -> Void) -> String? = { completion in
            completion(.success(5))
            return UUID.mock.uuidString
        }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            environment: .init(
                observeSecureUnreadMessageCount: observeMessageCount,
                unsubscribeFromUpdates: { _, _ in },
                queuesMonitor: queuesMonitor,
                engagementLauncher: engagementLauncher,
                theme: .mock(),
                log: .mock,
                isAuthenticated: isAuthenticated
            )
        )
        
        entryWidget.show(in: .init())

        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertTrue(mediaTypes.contains(.init(type: .secureMessaging, badgeCount: 5)))
        } else {
            XCTFail("Unexpected view state \(entryWidget.viewState)")
        }
    }
    
    func test_initStartsObservingSecureUnreadMessageCount() {
        var envCalls: [Call] = []
        
        let mockSubscriptionId = UUID.mock.uuidString
        let observeMessageCount: (_ completion: @escaping (Result<Int?, Error>) -> Void) -> String? = { _ in
            envCalls.append(.observeSecureUnreadMessageCount)
            return mockSubscriptionId
        }
        
        let entryWidget = EntryWidget(
            queueIds: [UUID.mock.uuidString],
            environment: .init(
                observeSecureUnreadMessageCount: observeMessageCount,
                unsubscribeFromUpdates: { _, _ in },
                queuesMonitor: .mock(),
                engagementLauncher: EngagementLauncher { _, _ in },
                theme: .mock(),
                log: .mock,
                isAuthenticated: { true }
            )
        )
        
        XCTAssertEqual(envCalls, [.observeSecureUnreadMessageCount])
        XCTAssertEqual(entryWidget.unreadSecureMessageSubscriptionId, mockSubscriptionId)
    }
}
