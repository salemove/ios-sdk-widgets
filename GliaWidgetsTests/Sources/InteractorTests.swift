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

    func test__enqueueForEngagement() throws {
        enum Call {
            case queueForEngagement
        }
        var coreSdkCalls = [Call]()

        var coreSdk = CoreSdkClient.failing
        coreSdk.queueForEngagement = { _, _, _ in
            coreSdkCalls.append(.queueForEngagement)
        }

        var interactorEnv = Interactor.Environment(coreSdk: coreSdk, queuesMonitor: .mock(), gcd: .failing, log: .failing)
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        interactor = .init(
            visitorContext: nil,
            environment: interactorEnv
        )

        interactor.enqueueForEngagement(engagementKind: .chat, replaceExisting: false) {} failure: {
            XCTFail($0.reason)
        }

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

    func test_sendMessagePreview() throws {
        enum Callback: Equatable {
            case sendMessagePreview(String)
        }

        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.sendMessagePreview = { message, _ in
            callbacks.append(.sendMessagePreview(message))
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.sendMessagePreview("mock")
        XCTAssertEqual(callbacks, [.sendMessagePreview("mock")])
    }

    func test_enqueueForEngagementSetsStateEnqueueing() throws {
        enum Callback: Equatable {
            case enqueueing
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1(.success(())) }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _ in }
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
        interactor.enqueueForEngagement(
            engagementKind: .chat, 
            replaceExisting: false,
            success: {},
            failure: { XCTFail($0.reason) }
        )

        XCTAssertEqual(callbacks, [.enqueueing])
    }

    func test_enqueueForEngagementSuccessSetsStateEnqueued() throws {
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
        interactorEnv.coreSdk.queueForEngagement = { _, _, completion in
            completion(.success(.mock))
        }
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
        interactor.enqueueForEngagement(
            engagementKind: .chat, 
            replaceExisting: false,
            success: {},
            failure: { XCTFail($0.reason) }
        )

        XCTAssertEqual(callbacks, [.enqueued])
    }

    func test_enqueueForEngagementFailureSetsStateEnded() throws {
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
        interactorEnv.coreSdk.queueForEngagement = { _, _, completion in
            completion(.failure(.mock()))
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

        interactor.enqueueForEngagement(
            engagementKind: .chat, 
            replaceExisting: false,
            success: { XCTFail("Should not be successful") },
            failure: { _ in callbacks.append(.failure) }
        )

        XCTAssertEqual(callbacks, [.ended, .failure])
    }
    
    func test_endSessionsCallsSuccessWhenStateIsNone() throws {
        enum Callback: Equatable {
            case success
        }
        var callbacks: [Callback] = []
        let interactor = Interactor.mock(environment: .failing)

        interactor.endSession { result in
            switch result {
            case .success:
                callbacks.append(.success)
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(callbacks, [.success])
    }

    func test_endSessionSetsStateNoneAndCallsSuccessWhenStateIsEnqueueing() throws {
        enum Callback: Equatable {
            case stateChangedToEnded
            case success
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
        
        interactor.endSession { result in
            switch result {
            case .success:
                callbacks.append(.success)
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(callbacks, [.stateChangedToEnded, .success])
    }

    func test_endSessionCallsCancelQueueWhenStateIsEnqueued() throws {
        enum Callback: Equatable {
            case cancelQueueCalled
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        interactorEnv.log = logger
        interactorEnv.coreSdk.cancelQueueTicket = { _, _ in
            callbacks.append(.cancelQueueCalled)
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.state = .enqueued(.mock, .chat)
        interactor.endSession { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(callbacks, [.cancelQueueCalled])
    }

    func test_endSessionEndsEngagementWhenStateIsEngaged() throws {
        enum Callback: Equatable {
            case endEngagementCalled
            case success
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.endEngagement = { _ in
            callbacks.append(.endEngagementCalled)
        }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.state = .engaged(.mock())
        interactor.endSession { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(callbacks, [.endEngagementCalled])
    }
    
    func test_exitQueueCallsCancelQueueTicketOnCoreSdkClient() throws {
        enum Callback: Equatable {
            case cancelQueueTicket
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        interactorEnv.log = logger
        interactorEnv.coreSdk.cancelQueueTicket = { _, _ in
            callbacks.append(.cancelQueueTicket)
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.exitQueue(
            ticket: .mock,
            completion: { _ in }
        )

        XCTAssertEqual(callbacks, [.cancelQueueTicket])
    }
    
    func test_endEngagementCallsEndEngagementOnCoreSdkClient() throws {
        enum Callback: Equatable {
            case endEngagement
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.endEngagement = { _ in
            callbacks.append(.endEngagement)
        }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.endEngagement { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(callbacks, [.endEngagement])
    }
    
    func test_startRequestsEngagedOperatorAndSetsStateToEngaged() throws {
        enum Callback: Equatable {
            case engaged
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.requestEngagedOperator = { $0([.mock()], nil) }
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

        interactor.start()

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

    func test_sendMessageCallsCoreSdkSendMessageWithAttachment() throws {
        enum Callback: Equatable {
            case sendMessageWithAttachment
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _, _ in
            callbacks.append(.sendMessageWithAttachment)
        }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1(.success(())) }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.send(messagePayload: .mock(content: "mock-message")) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail(error.reason)
            }
        }
        
        XCTAssertEqual(callbacks, [.sendMessageWithAttachment])
    }

    func test_sendMessageFailsWith401Error() throws {
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
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { payload, result in
            result(.failure(expectedError))
        }
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.send(messagePayload: .mock(content: "mock-message")) { result in
            switch result {
            case .success:
                callbacks.append(.success)
            case let .failure(error):
                switch error.error {
                case let authError as CoreSdkClient.Authentication.Error where authError == .expiredAccessToken:
                    callbacks.append(.expiredAccessToken)
                default:
                    callbacks.append(.unknownError)
                }
            }
        }

        XCTAssertEqual(callbacks, [.expiredAccessToken])
    }

    func test_onScreenSharingOfferSendsScreenShareOfferEvent() throws {
        enum Callback: Equatable {
            case screenShareOffered
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock
        let interactor = Interactor.mock(environment: interactorEnv)

        interactor.addObserver(self) { event in
            switch event {
            case .screenShareOffer:
                callbacks.append(.screenShareOffered)
            
            default:
                return
            }
        }

        interactor.onScreenSharingOffer({ _ in })

        XCTAssertEqual(callbacks, [.screenShareOffered])
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

    func test_endEngagementSetsStateToEndedByVisitor() {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        interactorEnv.coreSdk.endEngagement = { completion in completion(true, nil) }
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .engaged(.mock())

        interactor.endSession { _ in }

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
    
    func test_endAfterEnqueuedEngagementSetsEndedState() {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall
        )

        interactor.enqueueForEngagement(
            engagementKind: .audioCall, 
            replaceExisting: false,
            success: {},
            failure: { _ in }
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.endEngagement { _ in }
        XCTAssertEqual(interactor.state, .ended(.byVisitor))
    }

    func test_endSessionMakesCleanupWhenEngagementEndedByOperator() {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall,
            engagement: mockEngagement
        )

        interactor.enqueueForEngagement(
            engagementKind: .audioCall, 
            replaceExisting: false,
            success: {},
            failure: { _ in }
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.end(with: .operatorHungUp)
        XCTAssertEqual(interactor.state, .ended(.byOperator))
        XCTAssertEqual(interactor.endedEngagement, mockEngagement)

        interactor.endSession { _ in }
        XCTAssertEqual(interactor.state, .none)
        XCTAssertEqual(interactor.endedEngagement, nil)
    }
    
    func test_endSessionMakesCleanupWhenEngagementEndedForFollowUp() {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall,
            engagement: mockEngagement
        )

        interactor.enqueueForEngagement(
            engagementKind: .audioCall, 
            replaceExisting: false,
            success: {},
            failure: { _ in }
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.end(with: .followUp)
        XCTAssertEqual(interactor.state, .ended(.byOperator))
        XCTAssertEqual(interactor.endedEngagement, mockEngagement)

        interactor.endSession { _ in }
        XCTAssertEqual(interactor.state, .none)
        XCTAssertEqual(interactor.endedEngagement, nil)
    }

    func test_cleanupResetsStateAndNilifiesEndedEngagement() {
        let mockQueueTicket = CoreSdkClient.QueueTicket.mock
        let mockEngagement = CoreSdkClient.Engagement.mock(id: UUID.mock.uuidString)
        let interactor = makeEnqueuingSetupInteractor(
            with: mockQueueTicket,
            engagementKind: .audioCall,
            engagement: mockEngagement
        )

        interactor.enqueueForEngagement(
            engagementKind: .audioCall,
            replaceExisting: false,
            success: {},
            failure: { _ in }
        )
        XCTAssertEqual(interactor.state, .enqueued(mockQueueTicket, .audioCall))

        interactor.end(with: .followUp)
        XCTAssertEqual(interactor.state, .ended(.byOperator))
        XCTAssertEqual(interactor.endedEngagement, mockEngagement)

        interactor.cleanup()
        XCTAssertEqual(interactor.state, .none)
        XCTAssertEqual(interactor.endedEngagement, nil)
    }
}

extension InteractorTests {
    func makeEnqueuingSetupInteractor(
        with queueTicket: CoreSdkClient.QueueTicket,
        engagementKind: EngagementKind,
        engagement: CoreSdkClient.Engagement? = nil
    ) -> Interactor {
        var coreSdk = CoreSdkClient.failing
        coreSdk.queueForEngagement = { _, _, completion in
            completion(.success(queueTicket))
        }
        coreSdk.endEngagement = { completion in
            completion(true, nil)
        }
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
}
