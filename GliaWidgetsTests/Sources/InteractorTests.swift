import XCTest

@testable import GliaWidgets

class InteractorTests: XCTestCase {
    let mock = (
        queueId: "i'm-queue-identifier",
        config: Configuration.mock(
            authMethod: .siteApiKey(id: "id", secret: "secret"),
            environment: .usa,
            site: "mocked-id"
        ),
        visitorContext: CoreSdkClient.VisitorContext.mock
    )

    var interactor: Interactor!

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    func test__enqueueForEngagement() async throws {
        enum Call {
            case queueForEngagement
        }
        var coreSdkCalls = [Call]()

        var coreSdk = CoreSdkClient.failing
        coreSdk.queueForEngagement = { _, _ in
            coreSdkCalls.append(.queueForEngagement)
            return .mock
        }

        var interactorEnv = Interactor.Environment(coreSdk: coreSdk, queuesMonitor: .mock(), gcd: .failing, log: .failing)
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        interactor = .init(
            visitorContext: nil,
            environment: interactorEnv
        )

        try await interactor.enqueueForEngagement(engagementKind: .chat, replaceExisting: false)

        XCTAssertEqual(coreSdkCalls, [.queueForEngagement])
    }

    func test_onEngagementTransfer() throws {
        enum Call: Equatable {
            case stateChanged(InteractorState)
            case engagementTransferred(CoreSdkClient.Operator?)
        }

        var calls = [Call]()
        let mockOperator: CoreSdkClient.Operator = .mock()

        interactor = .init(
            visitorContext: nil,
            environment: .init(coreSdk: .failing, queuesMonitor: .mock(), gcd: .mock, log: .failing)
        )

        interactor.addObserver(self, handler: { event in
            switch event {
            case .stateChanged(let state):
                calls.append(.stateChanged(state))
            case .engagementTransferred(let engagedOperator):
                calls.append(.engagementTransferred(engagedOperator))
            default:
                break
            }
        })

        interactor.onEngagementTransfer([mockOperator])

        XCTAssertEqual(calls, [
            .stateChanged(.engaged(mockOperator)),
            .engagementTransferred(mockOperator)
        ])
    }

    func test_sendMessagePreview() async throws {
        enum Callback: Equatable {
            case sendMessagePreview(String)
        }

        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.sendMessagePreview = { message in
            callbacks.append(.sendMessagePreview(message))
            return true
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        _ = try await interactor.sendMessagePreview("mock")

        XCTAssertEqual(callbacks, [.sendMessagePreview("mock")])
    }

    func test_enqueueForEngagementSetsStateEnqueueing() async throws {
        enum Callback: Equatable {
            case enqueueing
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1(.success(())) }
        interactorEnv.coreSdk.queueForEngagement = { _, _ in .mock }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .enqueueing = state {
                    callbacks.append(.enqueueing)
                }
            default:
                return
            }
        }
        interactor.state = .enqueueing(.chat)
        try await interactor.enqueueForEngagement(
            engagementKind: .chat,
            replaceExisting: false
        )

        XCTAssertEqual(callbacks, [.enqueueing])
    }

    func test_enqueueForEngagementSuccessSetsStateEnqueued() async throws {
        enum Callback: Equatable {
            case enqueued
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        var log = CoreSdkClient.Logger.failing
        log.infoClosure = { _, _, _, _ in }
        log.prefixedClosure = { _ in log }
        interactorEnv.log = log
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1(.success(())) }
        interactorEnv.coreSdk.queueForEngagement = { _, _ in .mock }
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .enqueued = state {
                    callbacks.append(.enqueued)
                }
            default:
                return
            }
        }

        interactor.state = .enqueued(.mock, .chat)
        try await interactor.enqueueForEngagement(
            engagementKind: .chat,
            replaceExisting: false
        )

        XCTAssertEqual(callbacks, [.enqueued])
    }

    func test_enqueueForEngagementFailureSetsStateEnded() async throws {
        enum Callback: Equatable {
            case ended
            case failure
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        var log = interactorEnv.log
        log.prefixedClosure = { _ in log }
        log.infoClosure = { _, _, _, _ in }
        interactorEnv.log = log
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1(.success(())) }
        interactorEnv.coreSdk.queueForEngagement = { _, _ in
            throw CoreSdkClient.GliaCoreError.mock()
        }
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .ended = state {
                    callbacks.append(.ended)
                }
            default:
                return
            }
        }

        do {
            try await interactor.enqueueForEngagement(
                engagementKind: .chat,
                replaceExisting: false
            )
        } catch {
            callbacks.append(.failure)
        }

        XCTAssertEqual(callbacks, [.ended, .failure])
    }

    func test_endSessionSucceedsWhenStateIsNone() async throws {
        let interactor = Interactor.mock(environment: .failing)
        try await interactor.endSession()
    }

    func test_endSessionSetsStateNoneAndCallsSuccessWhenStateIsEnqueueing() async throws {
        enum Callback: Equatable {
            case stateChangedToEnded
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.state = .enqueueing(.chat)
        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .ended = state {
                    callbacks.append(.stateChangedToEnded)
                }
            default:
                return
            }
        }
        
        try await interactor.endSession()

        XCTAssertEqual(callbacks, [.stateChangedToEnded])
    }

    func test_endSessionCallsCancelQueueWhenStateIsEnqueued() async throws {
        enum Callback: Equatable {
            case cancelQueueCalled
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        interactorEnv.log = logger
        interactorEnv.coreSdk.cancelQueueTicket = { _ in
            callbacks.append(.cancelQueueCalled)
            return true
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.state = .enqueued(.mock, .chat)
        try await interactor.endSession()

        XCTAssertEqual(callbacks, [.cancelQueueCalled])
    }

    func test_endSessionEndsEngagementWhenStateIsEngaged() async throws {
        enum Callback: Equatable {
            case endEngagementCalled
        }
        var callbacks: [Callback] = []

        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.endEngagement = {
            callbacks.append(.endEngagementCalled)
            return true
        }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .engaged(.mock())
        try await interactor.endSession()

        XCTAssertEqual(callbacks, [.endEngagementCalled])
    }

    func test_exitQueueCallsCancelQueueTicketOnCoreSdkClient() async throws {
        enum Callback: Equatable {
            case cancelQueueTicket
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        interactorEnv.log = logger
        interactorEnv.coreSdk.cancelQueueTicket = { _ in
            callbacks.append(.cancelQueueTicket)
            return true
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        try await interactor.exitQueue(ticket: .mock)

        XCTAssertEqual(callbacks, [.cancelQueueTicket])
    }
    
    func test_endEngagementCallsEndEngagementOnCoreSdkClient() async throws {
        enum Callback: Equatable {
            case endEngagement
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.endEngagement = {
            callbacks.append(.endEngagement)
            return true
        }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        let interactor = Interactor.mock(environment: interactorEnv)

        try await interactor.endEngagement()

        XCTAssertEqual(callbacks, [.endEngagement])
    }

    func test_startRequestsEngagedOperatorAndSetsStateToEngaged() async throws {
        enum Callback: Equatable {
            case engaged
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.requestEngagedOperator = { [.mock()] }
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.state = .enqueueing(.chat)
        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .engaged = state {
                    callbacks.append(.engaged)
                }
            default:
                return
            }
        }

        await interactor.start()

        XCTAssertEqual(callbacks, [.engaged])
    }

    func test_endSetsStateToEnded() throws {
        enum Callback: Equatable {
            case ended
        }

        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .ended = state {
                    callbacks.append(.ended)
                }
            default:
                return
            }
        }

        interactor.end(with: .operatorHungUp)

        XCTAssertEqual(callbacks, [.ended])
    }

    func test_endWithFollowUpSetsStateToEnded() throws {
        enum Callback: Equatable {
            case ended
        }

        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.addObserver(self) { event in
            switch event {
            case .stateChanged(let state):
                if case .ended = state {
                    callbacks.append(.ended)
                }
            default:
                return
            }
        }

        interactor.end(with: .followUp)

        XCTAssertEqual(callbacks, [.ended])
    }

    func test_sendMessageCallsCoreSdkSendMessageWithAttachment() async throws {
        enum Callback: Equatable {
            case sendMessageWithAttachment
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .live
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _ in
            callbacks.append(.sendMessageWithAttachment)
            return .mock()
        }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1(.success(())) }
        let interactor = Interactor.mock(environment: interactorEnv)

        _ = try await interactor.send(messagePayload: .mock(content: "mock-message"))

        XCTAssertEqual(callbacks, [.sendMessageWithAttachment])
    }

    func test_sendMessageFailsWith401Error() async throws {
        enum Callback: Equatable {
            case success
            case expiredAccessToken
            case unknownError
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        let expectedError: CoreSdkClient.GliaCoreError = .init(
            reason: "Expired access token",
            error: CoreSdkClient.Authentication.Error.expiredAccessToken
        )
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { payload in
            throw expectedError
        }
        interactorEnv.gcd = .live
        let interactor = Interactor.mock(environment: interactorEnv)

        do {
            _ = try await interactor.send(messagePayload: .mock(content: "mock-message"))
        } catch CoreSdkClient.Authentication.Error.expiredAccessToken {
            callbacks.append(.expiredAccessToken)
        } catch let error as CoreSdkClient.GliaCoreError {
            switch error.error {
            case let authError as CoreSdkClient.Authentication.Error where authError == .expiredAccessToken:
                callbacks.append(.expiredAccessToken)
            default:
                callbacks.append(.unknownError)
            }
        }

        XCTAssertEqual(callbacks, [.expiredAccessToken])
    }
    
    func test_onMediaUpgradeOfferSendsMediaUpgradeOfferEvent() throws {
        enum Callback: Equatable {
            case mediaUpgradeOffered
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.addObserver(self) { event in
            switch event {
            case .upgradeOffer:
                callbacks.append(.mediaUpgradeOffered)
            default:
                return
            }
        }

        let mediaUpgradeOffer = try CoreSdkClient.MediaUpgradeOffer(
            type: .video,
            direction: .twoWay
        )

        interactor.onMediaUpgradeOffer(mediaUpgradeOffer, { _, _  in })

        XCTAssertEqual(callbacks, [.mediaUpgradeOffered])
    }

    func test_endEngagementSetsStateToEndedByVisitor() async throws {
        var env = Interactor.Environment.failing
        env.log.infoClosure = { _, _, _, _ in }
        env.log.prefixedClosure = { _ in env.log }
        env.coreSdk.endEngagement = { true }

        let interactor = Interactor.mock(environment: env)
        interactor.state = .engaged(.mock())

        try await interactor.endSession()

        XCTAssertEqual(interactor.state, .ended(.byVisitor))
    }

    func test_endWithReasonSetsProperState() {
        let interactor = Interactor.failing
        interactor.state = .engaged(.mock())
        typealias Item = (reason: CoreSdkClient.EngagementEndingReason, state: InteractorState)

        let items: [Item] = [
            (.visitorHungUp, .ended(.byVisitor)),
            (.operatorHungUp, .ended(.byOperator)),
            (.error, .ended(.byError))
        ]

        let test: (Item) -> Void = { item in
            interactor.end(with: item.reason)
            XCTAssertEqual(interactor.state, item.state)
        }

        items.forEach(test)
    }
    
    func test_endAfterEnqueuedEngagementSetsEndedState() async {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall
        )

        try? await interactor.enqueueForEngagement(
            engagementKind: .audioCall,
            replaceExisting: false
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        try? await interactor.endEngagement()
        XCTAssertEqual(interactor.state, .ended(.byVisitor))
    }

    func test_endSessionMakesCleanupWhenEngagementEndedByOperator() async throws {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall,
            engagement: mockEngagement
        )

        try? await interactor.enqueueForEngagement(
            engagementKind: .audioCall,
            replaceExisting: false
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.end(with: .operatorHungUp)
        XCTAssertEqual(interactor.state, .ended(.byOperator))
        XCTAssertEqual(interactor.endedEngagement, mockEngagement)

        try await interactor.endSession()
        XCTAssertEqual(interactor.state, .none)
        XCTAssertEqual(interactor.endedEngagement, nil)
    }
    
    func test_endSessionMakesCleanupWhenEngagementEndedForFollowUp() async throws {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall,
            engagement: mockEngagement
        )

        try? await interactor.enqueueForEngagement(
            engagementKind: .audioCall,
            replaceExisting: false
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.end(with: .followUp)
        XCTAssertEqual(interactor.state, .ended(.byOperator))
        XCTAssertEqual(interactor.endedEngagement, mockEngagement)

        try await interactor.endSession()
        XCTAssertEqual(interactor.state, .none)
        XCTAssertEqual(interactor.endedEngagement, nil)
    }

    func test_cleanupResetsStateAndNilifiesEndedEngagement() async {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall,
            engagement: mockEngagement
        )

        try? await interactor.enqueueForEngagement(
            engagementKind: .audioCall,
            replaceExisting: false
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.end(with: .followUp)
        XCTAssertEqual(interactor.state, .ended(.byOperator))
        XCTAssertEqual(interactor.endedEngagement, mockEngagement)

        interactor.cleanup()
        XCTAssertEqual(interactor.state, .none)
        XCTAssertEqual(interactor.endedEngagement, nil)
    }
    
    func test_interactorFailShouldRefetchAndRestartQueuesMonitor() {
        enum Call {
            case getQueues
            case subscribeForUpdates
        }
        var calls: [Call] = []
        let interactor = Interactor.failing
        let queuesMonitor = QueuesMonitor.mock()
        queuesMonitor.environment.getQueues = { completion in
            calls.append(.getQueues)
            completion(.success([.mock()]))
        }
        
        queuesMonitor.environment.subscribeForQueuesUpdates = { _, completion in
            calls.append(.subscribeForUpdates)
            completion(.success(.mock()))
            return UUID().uuidString
        }
        
        interactor.environment.queuesMonitor = queuesMonitor

        interactor.fail(error: .mock())
    
        XCTAssertEqual(calls, [.getQueues, .subscribeForUpdates])
    }
}

extension InteractorTests {
    func makeEnqueuingSetupInteractor(
        with queueTicket: CoreSdkClient.QueueTicket,
        engagementKind: EngagementKind,
        engagement: CoreSdkClient.Engagement? = nil
    ) -> Interactor {
        var coreSdk = CoreSdkClient.failing
        coreSdk.queueForEngagement = { _, _ in queueTicket }
        coreSdk.endEngagement = { true }
        coreSdk.getCurrentEngagement = {
            engagement
        }

        var interactorEnv = Interactor.Environment(coreSdk: coreSdk, queuesMonitor: .mock(), gcd: .failing, log: .failing)
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .enqueueing(engagementKind)

        return interactor
    }

    func test_onEngagementChangedCallsCleanupWhenEngagementIsNil() {
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock

        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.state = .engaged(.mock())
        interactor.setCurrentEngagement(mockEngagement)
        interactor.setEndedEngagement(mockEngagement)

        XCTAssertNotNil(interactor.currentEngagement)
        XCTAssertNotNil(interactor.endedEngagement)
        XCTAssertEqual(interactor.state, .engaged(.mock()))

        interactor.onEngagementChanged(nil)

        XCTAssertNil(interactor.currentEngagement)
        XCTAssertEqual(interactor.state, .none)
    }

    func test_onEngagementChangedTransitionFromEngagementToNil() {
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock

        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .enqueueing(.chat)

        interactor.onEngagementChanged(mockEngagement)

        XCTAssertNotNil(interactor.currentEngagement)
        XCTAssertNotNil(interactor.endedEngagement)

        interactor.onEngagementChanged(nil)

        XCTAssertNil(interactor.currentEngagement)
        XCTAssertEqual(interactor.state, .none)
    }

    func test_onEngagementChangedSetsEngagementWhenNonNil() {
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock

        let interactor = Interactor.mock(environment: interactorEnv)

        XCTAssertNil(interactor.currentEngagement)
        XCTAssertNil(interactor.endedEngagement)

        interactor.onEngagementChanged(mockEngagement)

        // Both current and ended engagement should be set
        XCTAssertEqual(interactor.currentEngagement?.id, mockEngagement.id)
        XCTAssertEqual(interactor.endedEngagement?.id, mockEngagement.id)
    }
}
