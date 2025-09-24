import XCTest
import Combine

@testable import GliaWidgets

class EntryWidgetTests: XCTestCase {
    private enum Call: Equatable {
        case observeSecureUnreadMessageCount
        case start(EngagementKind)
    }

    @MainActor
    func test_secureMessagingIsHiddenWhenUserIsNotAuthenticated() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { false }

        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor

        _ = try await queuesMonitor.fetchAndMonitorQueues()

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

    @MainActor
    func test_secureMessagingIsShownWhenUserIsAuthenticated() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor

        _ = try await queuesMonitor.fetchAndMonitorQueues()

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

    @MainActor
    func test__secureMessagingIsShownWhenUserIsAuthenticatedAndHasUnreadMessages() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let observeMessageCount: (_ completion: @escaping (Result<Int?, Error>) -> Void) -> String? = { completion in
            completion(.success(5))
            return UUID.mock.uuidString
        }

        var environment = EntryWidget.Environment.mock()
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor
        environment.observeSecureUnreadMessageCount = observeMessageCount

        _ = try await queuesMonitor.fetchAndMonitorQueues()
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
        environment.hasPendingInteractionPublisher = Just(true).eraseToAnyPublisher()
        environment.engagementLauncher = engagementLauncher

        let entryWidget = EntryWidget(
            queueIds: [UUID.mock.uuidString],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(envCalls, [.start(.messaging(.welcome))])
    }
    
    func test_mediaTypesSortedWithNoFilters() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio, .video, .text])

        var environment = EntryWidget.Environment.mock()
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor
        environment.observeSecureUnreadMessageCount = { result in
            result(.success(5))
            return UUID.mock.uuidString
        }

        _ = try await queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

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
    
    func test_mediaTypesSortedAndFilteredIfUserNotAuthenticated() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio, .video, .text])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        _ = try await queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

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
    
    func test_mediaTypesSortedAndFilteredSecureConversation() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio, .video, .text])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        _ = try await queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

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

    func test_messagingIsShownWhenHasPendingInteractionIsTrueAndQueueDoesNotSupportMessaging() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.audio, .video, .text])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        _ = try await queuesMonitor.fetchAndMonitorQueues(queuesIds: [mockQueueId])

        var environment = EntryWidget.Environment.mock()
        environment.hasPendingInteractionPublisher = Just(true).eraseToAnyPublisher()
        environment.queuesMonitor = queuesMonitor
        environment.observeSecureUnreadMessageCount = { result in
            result(.success(5))
            return UUID.mock.uuidString
        }
        let configuration = EntryWidget.Configuration.mock(filterSecureConversation: false)
        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: configuration,
            environment: environment
        )

        XCTAssertEqual(
            entryWidget.viewState,
            .mediaTypes([.init(type: .video), .init(type: .audio), .init(type: .chat), .init(type: .secureMessaging, badgeCount: 5)])
        )
    }

    func test_ongoingEngagementViewStateIsShownWhenCoreEngagementIsChat() {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { false }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock())
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { false }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(media: .init(audio: .twoWay, video: nil)))
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { false }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(media: .init(audio: .twoWay, video: .twoWay)))
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { false }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(source: .callVisualizer))
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())
        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.video))
    }

    @MainActor
    func test_viewStateShowsMessagingWhenTransferredSCExists() async throws {
        var environment = EntryWidget.Environment.mock()
        let interactor: Interactor = .mock()
        interactor.state = .engaged(nil)
        interactor.setCurrentEngagement(.mock(
            source: .coreEngagement,
            status: .transferring,
            capabilities: .init(text: true)
        ))
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()
        environment.hasPendingInteractionPublisher = Just(true).eraseToAnyPublisher()
        
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.text, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        environment.isAuthenticated = { true }
        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor

        _ = try await queuesMonitor.fetchAndMonitorQueues()

        let entryWidget = EntryWidget(
            queueIds: [],
            configuration: .default,
            environment: environment
        )

        entryWidget.embed(in: .init())
        XCTAssertEqual(entryWidget.viewState, .mediaTypes([.init(type: .audio), .init(type: .chat), .init(type: .secureMessaging)]))
    }

    func test_callVisualizerResumeCallbackBeingCalled() {
        enum Call {
            case onCallVisualizerResume
        }
        var calls: [Call] = []
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock(source: .callVisualizer))
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()
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
        queueMonitorEnvironment.getQueues = { [mockQueue] }
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
        environment.interactorPublisher = Just(interactor).eraseToAnyPublisher()

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())
        XCTAssertTrue(logs.contains(expectedLogMessage))
    }

    func test_widgetUpdatesWhenInteractorChanges() {
        let interactorSubject = CurrentValueSubject<Interactor?, Never>(nil)
        var environment = EntryWidget.Environment.mock()
        environment.interactorPublisher = interactorSubject.eraseToAnyPublisher()
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, media: [.messaging, .audio])
        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        environment.queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )
        entryWidget.show(in: .init())
        let oldInteractor = Interactor.mock()
        oldInteractor.setCurrentEngagement(.mock())
        interactorSubject.send(oldInteractor)
        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.chat))

        let newInteractor = Interactor.mock()
        newInteractor.setCurrentEngagement(.mock(media: .init(audio: .twoWay, video: nil)))
        interactorSubject.send(newInteractor)
        XCTAssertEqual(entryWidget.viewState, .ongoingEngagement(.audio))
    }

    @MainActor
    func test_secureMessagingIsShownIfQueueIsUnstaffedOrFullAndSCAvailable() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, status: .unstaffed, media: [.messaging, .audio, .video])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { true }

        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor

        _ = try await queuesMonitor.fetchAndMonitorQueues()

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())
        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertEqual(mediaTypes, [.init(type: .secureMessaging)])
        } else {
            XCTFail("Unexpected view state \(entryWidget.viewState)")
        }
    }

    @MainActor
    func test_offlineIsShownIfQueueIsUnstaffedOrFullAndSCNotAvailable() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, status: .full, media: [.audio, .video])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { true }

        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor

        _ = try await queuesMonitor.fetchAndMonitorQueues()

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        XCTAssertEqual(entryWidget.viewState, .offline)
    }

    @MainActor
    func test_entryWidgetShowsMediaIfAnyQueueIsOpen() async throws {
        let mockQueueId = "mockQueueId"
        let mockQueue = Queue.mock(id: mockQueueId, status: .open, media: [.audio, .video])
        let openMockQueue = Queue.mock(id: mockQueueId, status: .full, media: [.audio, .video])

        var queueMonitorEnvironment: QueuesMonitor.Environment = .mock
        queueMonitorEnvironment.getQueues = { [mockQueue] }
        queueMonitorEnvironment.subscribeForQueuesUpdates = { _, completion in
            completion(.success(mockQueue))
            return UUID.mock.uuidString
        }
        var environment = EntryWidget.Environment.mock()
        environment.isAuthenticated = { true }

        let queuesMonitor = QueuesMonitor(environment: queueMonitorEnvironment)
        environment.queuesMonitor = queuesMonitor

        _ = try await queuesMonitor.fetchAndMonitorQueues()

        let entryWidget = EntryWidget(
            queueIds: [mockQueueId],
            configuration: .default,
            environment: environment
        )

        entryWidget.show(in: .init())

        entryWidget.show(in: .init())
        if case let .mediaTypes(mediaTypes) = entryWidget.viewState {
            XCTAssertEqual(mediaTypes, [.init(type: .video), .init(type: .audio)])
        } else {
            XCTFail("Unexpected view state \(entryWidget.viewState)")
        }
    }
}
