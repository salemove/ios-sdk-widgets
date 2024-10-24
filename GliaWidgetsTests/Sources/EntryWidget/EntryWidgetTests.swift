import XCTest
import Combine
import GliaCoreSDK

@testable import GliaWidgets

class EntryWidgetTests: XCTestCase {

    func test_secureMessagingIsHiddenWhenUserIsNotAuthenticated() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID().uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)


        var engagementLauncher = EngagementLauncher { _, _ in }
        var isAuthenticated: () -> Bool = { false }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            environment: .init(
                queuesMonitor: queuesMonitor,
                engagementLauncher: engagementLauncher,
                theme: Theme(),
                isAuthenticated: isAuthenticated
            )
        )

        entryWidget.show(in: .init())

        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertFalse(mediaTypes.contains(.secureMessaging))
        } else {
            XCTFail("Unexpected view state")
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
            return UUID().uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        var engagementLauncher = EngagementLauncher { _, _ in }
        var isAuthenticated: () -> Bool = { true }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            environment: .init(
                queuesMonitor: queuesMonitor,
                engagementLauncher: engagementLauncher,
                theme: Theme(),
                isAuthenticated: isAuthenticated
            )
        )

        entryWidget.show(in: .init())

        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertTrue(mediaTypes.contains(.secureMessaging))
        } else {
            XCTFail("Unexpected view state")
        }
    }
}
