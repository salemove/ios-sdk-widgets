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
    
    func test_mediaTypesSortedWithNoFilters() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio, .video, .text])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        
        var environment = EntryWidget.Environment.mock()
        environment.queuesMonitor = queuesMonitor
        environment.observeSecureUnreadMessageCount = { result in
            result(.success(5))
            return UUID.mock.uuidString
        }
        
        
        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        XCTAssertEqual(
            entryWidget.viewState,
            .mediaTypes([.init(type: .video), .init(type: .audio), .init(type: .chat), .init(type: .secureMessaging, badgeCount: 5)])
        )
    }
    
    func test_mediaTypesSortedAndFilteredIfUserNotAuthenticated() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio, .video, .text])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])
        
        var environment = EntryWidget.Environment.mock()
        environment.queuesMonitor = queuesMonitor
        environment.observeSecureUnreadMessageCount = { result in
            result(.success(5))
            return UUID.mock.uuidString
        }
        environment.isAuthenticated = {
            false
        }
        
        
        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        XCTAssertEqual(
            entryWidget.viewState,
            .mediaTypes([.init(type: .video), .init(type: .audio), .init(type: .chat)])
        )
    }
    
    func test_mediaTypesSortedAndFilteredSecureConversation() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio, .video, .text])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.listQueues = { completion in
            completion([mockQueue], nil)
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        var environment = EntryWidget.Environment.mock()
        environment.queuesMonitor = queuesMonitor
        environment.observeSecureUnreadMessageCount = { result in
            result(.success(5))
            return UUID.mock.uuidString
        }
        let configuration = EntryWidget.Configuration.mock(filterSecureConversation: true)
        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: configuration,
            environment: environment
        )

        XCTAssertEqual(
            entryWidget.viewState,
            .mediaTypes([.init(type: .video), .init(type: .audio), .init(type: .chat)])
        )
    }

    func test_ongoingEngagementViewStateIsShownWhenCoreEngagementIsChat() {
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
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock())
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.chat))
    }

    func test_ongoingEngagementViewStateIsShownWhenCoreEngagementIsAudio() {
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
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(media: .init(audio: .twoWay, video: nil)))
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.audio))
    }

    func test_ongoingEngagementViewStateIsShownWhenCoreEngagementIsVideo() {
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
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(media: .init(audio: .twoWay, video: .twoWay)))
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.video))
    }

    func test_ongoingEngagementViewStateIsShownWhenCallVisualizer() {
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
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(source: .callVisualizer))
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.callVisualizer))
    }

    func test_ongoingEngagementViewStateIsShownWhenEnqueuedToChat() {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .enqueued(.mock, .chat)
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.chat))
    }

    func test_ongoingEngagementViewStateIsShownWhenEnqueuedToAudio() {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .enqueued(.mock, .audioCall)
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.audio))
    }

    func test_ongoingEngagementViewStateIsShownWhenEnqueuedToVideo() {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .enqueued(.mock, .videoCall)
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.video))
    }
    
    func test_ongoingEngagementViewStateIsShownWhenEnqueueingToChat() {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .enqueueing(.chat)
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.chat))
    }

    func test_ongoingEngagementViewStateIsShownWhenEnqueueingToAudio() {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .enqueueing(.audioCall)
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.audio))
    }

    func test_ongoingEngagementViewStateIsShownWhenEnqueueingToVideo() {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .enqueueing(.videoCall)
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.video))
    }

    func test_callVisualizerResumeCallbackBeingCalled() {
        enum Call {
            case onCallVisualizerResume
        }
        var calls: [Call] = []
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
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(source: .callVisualizer))
        environment.currentInteractor = { interactor }
        environment.onCallVisualizerResume = {
            calls.append(.onCallVisualizerResume)
        }
        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.mediaTypeSelected(.init(type: .callVisualizer))

        XCTAssertEqual(calls, [.onCallVisualizerResume])
    }

    func test_ongoingEngagementLogMessageIsReceived() {
        var logs: [String] = []
        let expectedLogMessage = "Preparing items based on ongoing engagement"
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
        environment.log.infoClosure = { logMessage, _, _, _ in
            if let logMessageString = logMessage as? String {
                logs.append(logMessageString)
            }
        }
        environment.isAuthenticated = { false }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(media: .init(audio: .twoWay, video: .twoWay)))
        environment.currentInteractor = { interactor }

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())
        XCTAssertTrue(logs.contains(expectedLogMessage))
    }
}
