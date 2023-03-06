import XCTest

@testable import GliaWidgets

class InteractorTests: XCTestCase {

    let mock = (
        queueId: "i'm-queue-identifier",
        config: Configuration.mock(
            authMethod: .appToken("mocked-app-token"),
            environment: .usa,
            site: "mocked-id"
        ),
        visitorContext: CoreSdkClient.VisitorContext.mock
    )

    var interactor: Interactor!

    func test__enqueueForEngagement() throws {

        enum Call {
            case configureWithConfiguration, configureWithInteractor, queueForEngagement
        }
        var coreSdkCalls = [Call]()

        var coreSdk = CoreSdkClient.failing
        coreSdk.configureWithConfiguration = { _, completion in
            coreSdkCalls.append(.configureWithConfiguration)
            completion?()
        }
        coreSdk.configureWithInteractor = { _ in
            coreSdkCalls.append(.configureWithInteractor)
        }
        coreSdk.queueForEngagement = { _, _, _, _, _, _ in
            coreSdkCalls.append(.queueForEngagement)
        }
        interactor = .init(
            configuration: mock.config,
            queueID: mock.queueId,
            environment: .init(coreSdk: coreSdk, gcd: .failing)
        )

        interactor.enqueueForEngagement(mediaType: .text) {} failure: {
            XCTFail($0.reason)
        }

        XCTAssertEqual(coreSdkCalls, [
            .configureWithInteractor,
            .configureWithConfiguration,
            .queueForEngagement
        ])
    }

    func test__isConfigurationPerformedIsInitiallyFalse() {
        XCTAssertFalse(Interactor.mock(environment: .failing).isConfigurationPerformed)
    }

    func test__isConfigurationPerformedBecomesTrue() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { _, _ in }
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.withConfiguration {}
        XCTAssertTrue(interactor.isConfigurationPerformed)
    }

    func test__configureWithConfigurationPerformedOnce() {
        enum Call {
            case configureWithConfiguration
        }
        var calls: [Call] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { _, _ in
            calls.append(.configureWithConfiguration)
        }
        let interactor = Interactor.mock(environment: interactorEnv)
        for _ in 0 ..< 1000 {
            interactor.withConfiguration {}
        }
        XCTAssertEqual(calls, [.configureWithConfiguration])
    }

    func test_withConfigurationInvokesCompletionForFirstAndNextCalls() {
        enum Callback {
            case withConfiguration
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1?() }
        let interactor = Interactor.mock(environment: interactorEnv)
        for _ in 0 ..< 3 {
            interactor.withConfiguration {
                callbacks.append(.withConfiguration)
            }
        }

        XCTAssertEqual(callbacks, [.withConfiguration, .withConfiguration, .withConfiguration])
    }

    func test_onEngagementTransfer() throws {
        enum Call: Equatable {
            case stateChanged(InteractorState)
            case engagementTransferred(CoreSdkClient.Operator?)
        }
    
        var calls = [Call]()
        let mockOperator: CoreSdkClient.Operator = .mock()

        interactor = .init(
            configuration: mock.config,
            queueID: mock.queueId,
            environment: .init(coreSdk: .failing, gcd: .mock)
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
        interactorEnv.coreSdk.configureWithConfiguration = { $1?() }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _, _, _, _ in }
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
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1?() }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _, _, _, completion in
            completion(.mock, nil)
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
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1?() }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _, _, _, completion in
            completion(nil, .mock())
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
        
        interactor.state = .enqueueing
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
        
        interactor.state = .enqueueing
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

        interactor.end()

        XCTAssertEqual(callbacks, [.ended])
    }
    
    func test_sendMessageCallsCoreSdkSendMessageWithAttachment() throws {
        enum Callback: Equatable {
            case sendMessageWithAttachment
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.sendMessageWithAttachment = { _, _, _ in
            callbacks.append(.sendMessageWithAttachment)
        }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1?() }
        let interactor = Interactor.mock(environment: interactorEnv)
        
        interactor.send(
            "mock-message",
            attachment: nil,
            success: { _ in },
            failure: { XCTFail($0.reason) }
        )
        
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
}
