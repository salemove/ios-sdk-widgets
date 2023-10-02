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
        coreSdk.queueForEngagement = { _, _ in
            coreSdkCalls.append(.queueForEngagement)
        }

        var interactorEnv = Interactor.Environment(coreSdk: coreSdk, gcd: .failing, log: .failing)
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        interactor = .init(
            visitorContext: nil,
            queueIds: [mock.queueId],
            environment: interactorEnv
        )

        interactor.enqueueForEngagement(mediaType: .text) {} failure: {
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
            queueIds: [mock.queueId],
            environment: .init(coreSdk: .failing, gcd: .mock, log: .failing)
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
        interactorEnv.coreSdk.queueForEngagement = { _, _ in }
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
        interactor.state = .enqueueing(.text)
        interactor.enqueueForEngagement(
            mediaType: .text,
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
        interactorEnv.coreSdk.queueForEngagement = { _, completion in
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

        interactor.state = .enqueued(.mock)
        interactor.enqueueForEngagement(
            mediaType: .text,
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
        interactorEnv.coreSdk.queueForEngagement = { _, completion in
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
            mediaType: .text,
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

        interactor.endSession(
            success: { callbacks.append(.success) },
            failure: { XCTFail($0.reason) }
        )
        
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
        
        interactor.state = .enqueueing(.text)
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
        
        interactor.endSession(
            success: { callbacks.append(.success) },
            failure: { XCTFail($0.reason) }
        )
        
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
        
        interactor.state = .enqueued(.mock)
        interactor.endSession(
            success: {},
            failure: { XCTFail($0.reason) }
        )
        
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
        interactor.endSession(
            success: {},
            failure: { XCTFail($0.reason) }
        )
        
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
            success: {},
            failure: { XCTFail($0.reason) }
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

        interactor.endEngagement(
            success: {},
            failure: { XCTFail($0.reason) }
        )

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
        
        interactor.state = .enqueueing(.text)
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

        interactor.endSession(success: {}, failure: { _ in })

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
}
