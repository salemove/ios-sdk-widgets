import XCTest
import Combine
import GliaCoreSDK

@testable import GliaWidgets

class EntryWidgetTests: XCTestCase {
    private enum Call: Equatable {
        case observeSecureUnreadMessageCount
        case start(EngagementKind)
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
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { false }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
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
        var environment = EntryWidget.Environment.mock()
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
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
        let observeMessageCount: (_ completion: @escaping (Result<Int?, Error>) -> Void) -> String? = { completion in
            completion(.success(5))
            return UUID.mock.uuidString
        }

        var environment = EntryWidget.Environment.mock()
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.observeSecureUnreadMessageCount = observeMessageCount

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
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
        
        var environment = EntryWidget.Environment.mock()
        environment.observeSecureUnreadMessageCount = observeMessageCount

        let entryWidget = EntryWidget(
            queueIds: [UUID.mock.uuidString],
            configuration: .default,
            environment: environment
        )
        
        XCTAssertEqual(envCalls, [.observeSecureUnreadMessageCount])
        XCTAssertEqual(entryWidget.unreadSecureMessageSubscriptionId, mockSubscriptionId)
    }

    func test_secureMessagingIsOpenedIfPendingInteractionExists() {
        var envCalls: [Call] = []

        let engagementLauncher = EngagementLauncher { engagementKind, _ in
            envCalls.append(.start(engagementKind))
        }
        var environment = EntryWidget.Environment.mock()
        environment.hasPendingInteraction = { true }
        environment.engagementLauncher = engagementLauncher

        let entryWidget = EntryWidget(
            queueIds: [UUID.mock.uuidString],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(envCalls, [.start(.messaging(.welcome))])
    }
}
