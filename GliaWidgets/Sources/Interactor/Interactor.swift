import Foundation
import Combine

enum InteractorState {
    case none
    case enqueueing(EngagementKind)
    case enqueued(CoreSdkClient.QueueTicket, EngagementKind)
    case engaged(CoreSdkClient.Operator?)
    case ended(EndEngagementReason)

    var isEnded: Bool {
        guard case .ended = self else { return false }
        return true
    }

    var enqueueingEngagementKind: EngagementKind? {
        switch self {
        case .enqueued(_, let engagementKind), .enqueueing(let engagementKind):
            return engagementKind
        case .none, .engaged, .ended:
            return nil
        }
    }
}

enum EndEngagementReason {
    case byOperator
    case byVisitor
    case byError
}

enum InteractorEvent {
    case stateChanged(InteractorState)
    case receivedMessage(CoreSdkClient.Message)
    case messagesUpdated([CoreSdkClient.Message])
    case typingStatusUpdated(CoreSdkClient.OperatorTypingStatus)
    case upgradeOffer(CoreSdkClient.MediaUpgradeOffer, answer: CoreSdkClient.AnswerWithSuccessBlock)
    case updateOffer(CoreSdkClient.MediaUpgradeOffer)
    case audioStreamAdded(CoreSdkClient.AudioStreamable)
    case audioStreamError(CoreSdkClient.SalemoveError)
    case videoStreamAdded(CoreSdkClient.VideoStreamable)
    case videoStreamError(CoreSdkClient.SalemoveError)
    case screenShareOffer(answer: CoreSdkClient.AnswerBlock)
    case screenShareError(error: CoreSdkClient.SalemoveError)
    case screenSharingStateChanged(to: CoreSdkClient.VisitorScreenSharingState)
    case error(CoreSdkClient.SalemoveError)
    case engagementTransferred(CoreSdkClient.Operator?)
    case engagementTransferring
    case onLiveToSecureConversationsEngagementTransferring
    case onEngagementRequest(CoreSdkClient.Request, answer: Command<Bool>)
}

class Interactor {
    typealias EventHandler = (InteractorEvent) -> Void

    @Published private(set) var queueIds: [String]?

    var engagedOperator: CoreSdkClient.Operator? {
        switch state {
        case .engaged(let engagedOperator):
            return engagedOperator
        default:
            return nil
        }
    }

    var isEngaged: Bool {
        switch state {
        case .engaged:
            return true
        default:
            return false
        }
    }

    let visitorContext: Configuration.VisitorContext?
    @Published private(set) var currentEngagement: CoreSdkClient.Engagement?

    // Used to save engagement ended by operator to fetch a survey
    private(set) var endedEngagement: CoreSdkClient.Engagement?

    private var observers = [() -> (AnyObject?, EventHandler)]()
    private var cancellables = Set<AnyCancellable>()
    @Published var state: InteractorState = .none
    var environment: Environment

    /// Skips Live Observation confirmation alerts/snackbars in
    /// specific cases. For example after restarting engagement
    /// after authentication.
    var skipLiveObservationConfirmations = false

    init(
        visitorContext: Configuration.VisitorContext?,
        environment: Environment
    ) {
        self.visitorContext = visitorContext
        self.environment = environment

        $state
            .removeDuplicates()
            .sink { [weak self] newState in
                self?.notify(.stateChanged(newState))
            }
            .store(in: &cancellables)
        $queueIds
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] queueIds in
                self?.environment.queuesMonitor.fetchAndMonitorQueues(queuesIds: queueIds)
            }
            .store(in: &cancellables)
    }

    func addObserver(_ observer: AnyObject, handler: @escaping EventHandler) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append { [weak observer] in (observer, handler) }
    }

    func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
    }

    func notify(_ event: InteractorEvent) {
        observers
            .compactMap { $0() }
            .filter { $0.0 != nil }
            .forEach {
                let handler = $0.1

                environment.gcd.mainQueue.async {
                    handler(event)
                }
            }
    }
}

extension Interactor {
    func setQueuesIds(_ queueIds: [String]) {
        self.queueIds = queueIds
    }

    func enqueueForEngagement(
        engagementKind: EngagementKind,
        replaceExisting: Bool,
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        switch engagementKind {
        case .chat:
             environment.log.prefixed(Self.self).info("Start queueing for chat engagement")
        case .audioCall, .videoCall:
            environment.log.prefixed(Self.self).info("Start queueing for media engagement")
        case .messaging, .none:
            break
        }

        let options = engagementKind == .audioCall || engagementKind == .videoCall
        ? CoreSdkClient.EngagementOptions(mediaDirection: .twoWay)
        : nil

        let coreSdkVisitorContext: CoreSdkClient.VisitorContext? = (self.visitorContext?.assetId)
            .map(CoreSdkClient.VisitorContext.AssetId.init(rawValue:))
            .map(CoreSdkClient.VisitorContext.ContextType.assetId)
            .map(CoreSdkClient.VisitorContext.init(_:))

        self.environment.coreSdk.queueForEngagement(
            .init(
                queueIds: queueIds ?? [],
                visitorContext: coreSdkVisitorContext,
                // shouldCloseAllQueues is `true` by default core sdk,
                // here it is passed explicitly
                shouldCloseAllQueues: true,
                mediaType: engagementKind.mediaType,
                engagementOptions: options
            ),
            replaceExisting
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.environment.log.prefixed(Self.self).info("Queue for engagement stopped due to error or empty queue")
                self?.state = .ended(.byError)
                failure(error)
            case .success(let ticket):

                if case .enqueueing = self?.state {
                    self?.state = .enqueued(ticket, engagementKind)
                }
                success()
            }
        }
    }

    func sendMessagePreview(_ message: String) {
        environment.coreSdk.sendMessagePreview(message) { _, _ in }
    }

    func send(
        messagePayload: CoreSdkClient.SendMessagePayload,
        completion: @escaping (Result<CoreSdkClient.Message, CoreSdkClient.GliaCoreError>) -> Void
    ) {
        environment.coreSdk.sendMessageWithMessagePayload(messagePayload, completion)
    }

    func endSession(completion: @escaping (Result<Void, Error>) -> Void) {
        switch state {
        case .none:
            completion(.success(()))
        case .enqueueing:
            state = .ended(.byVisitor)
            completion(.success(()))
        case let .enqueued(ticket, _):
            exitQueue(
                ticket: ticket,
                completion: completion
            )
        case .engaged where currentEngagement?.isTransferredSecureConversation == true:
            completion(.success(()))
        case .engaged:
            endEngagement(completion: completion)
        case .ended:
            completion(.success(()))

            // `cleanup` is called once survey fetching is already initiated,
            // so no need to store `endedEngagement` anymore.
            cleanup()
        }
    }

    func exitQueue(
        ticket: CoreSdkClient.QueueTicket,
        completion: @escaping (Result<Void, Error>) -> Void
) {
        environment.log.prefixed(Self.self).info("Cancel queue ticket")
        environment.coreSdk.cancelQueueTicket(ticket) { [weak self] _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self?.state = .ended(.byVisitor)
                completion(.success(()))
            }
        }
    }

    func endEngagement(completion: @escaping (Result<Void, Error>) -> Void) {
        environment.coreSdk.endEngagement { [weak self] _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self?.state = .ended(.byVisitor)
                completion(.success(()))
            }
        }
    }

    func cleanup() {
        state = .none
        endedEngagement = nil
    }
}

// MARK: - Interactable

extension Interactor: CoreSdkClient.Interactable {
    var onEngagementChanged: CoreSdkClient.EngagementChangedBlock {
        return { [weak self] engagement in
            self?.currentEngagement = engagement
        }
    }

    var onScreenSharingOffer: CoreSdkClient.ScreenshareOfferBlock {
        return { [weak self] answer in
            self?.notify(.screenShareOffer(answer: answer))
        }
    }

    var onMediaUpgradeOffer: CoreSdkClient.MediaUgradeOfferBlock {
        return { [weak self] offer, answer in
            self?.notify(.upgradeOffer(offer, answer: answer))
        }
    }

    var onEngagementTransferMediaUpdate: CoreSdkClient.MediaUpdateBlock {
        return { [weak self] offer in
            self?.notify(.updateOffer(offer))
        }
    }

    var onEngagementRequest: CoreSdkClient.RequestOfferBlock {
        return { [weak self] request, answer  in
            let action = Command<Bool> { agreed in
                let completion: CoreSdkClient.SuccessBlock = { _, error in
                    if let reason = error?.reason {
                        debugPrint(reason)
                    }
                }
                let coreSdkVisitorContext: CoreSdkClient.VisitorContext? = (self?.visitorContext?.assetId)
                    .map(CoreSdkClient.VisitorContext.AssetId.init(rawValue:))
                    .map(CoreSdkClient.VisitorContext.ContextType.assetId)
                    .map(CoreSdkClient.VisitorContext.init(_:))
                answer(coreSdkVisitorContext, agreed, completion)
            }
            self?.notify(.onEngagementRequest(request, answer: action))
        }
    }

    var onEngagementTransfer: CoreSdkClient.EngagementTransferBlock {
        return { [weak self] operators in
            let engagedOperator = operators?.first

            self?.state = .engaged(engagedOperator)
            self?.notify(.engagementTransferred(engagedOperator))
        }
    }

    var onEngagementTransferring: CoreSdkClient.EngagementTransferringBlock {
        return { [weak self, environment] in
            environment.log.prefixed(Self.self).info(
                "Transfer engagement",
                function: "\(\Interactor.onEngagementTransferring)"
            )
            self?.notify(.engagementTransferring)
        }
    }

    var onLiveToSecureConversationsEngagementTransferring: CoreSdkClient.EngagementTransferringBlock {
        return { [weak self, environment] in
            environment.log.prefixed(Self.self).info(
                "Live to Secure Conversations Engagement Transfer",
                function: "\(\Interactor.onLiveToSecureConversationsEngagementTransferring)"
            )
            self?.notify(.onLiveToSecureConversationsEngagementTransferring)
        }
    }

    var onOperatorTypingStatusUpdate: CoreSdkClient.OperatorTypingStatusUpdate {
        return { [weak self] operatorTypingStatus in
            self?.notify(.typingStatusUpdated(operatorTypingStatus))
        }
    }

    var onMessagesUpdated: CoreSdkClient.MessagesUpdateBlock {
        return { [weak self] messages in
            self?.notify(.messagesUpdated(messages))
        }
    }

    var onVisitorScreenSharingStateChange: CoreSdkClient.VisitorScreenSharingStateChange {
        return { [weak self] state, error in
            if let error = error {
                self?.notify(.screenShareError(error: error))
            } else {
                self?.notify(.screenSharingStateChanged(to: state))
            }
        }
    }

    var onAudioStreamAdded: CoreSdkClient.AudioStreamAddedBlock {
        return { [weak self] stream, error in
            guard let self else { return }
            if let stream = stream {
                notify(.audioStreamAdded(stream))
                currentEngagement = environment.coreSdk.getCurrentEngagement()
            } else if let error = error {
                notify(.audioStreamError(error))
            }
        }
    }

    var onVideoStreamAdded: CoreSdkClient.VideoStreamAddedBlock {
        return { [weak self] stream, error in
            guard let self else { return }
            if let stream = stream {
                notify(.videoStreamAdded(stream))
                currentEngagement = environment.coreSdk.getCurrentEngagement()
            } else if let error = error {
                notify(.videoStreamError(error))
            }
        }
    }

    func receive(message: CoreSdkClient.Message) {
        notify(.receivedMessage(message))
    }

    func start() {
        environment.coreSdk.requestEngagedOperator { [weak self] operators, _ in
            let engagedOperator = operators?.first
            self?.state = .engaged(engagedOperator)
        }
        currentEngagement = environment.coreSdk.getCurrentEngagement()
    }

    func start(engagement: CoreSdkClient.Engagement) {
        switch engagement.source {
        case .coreEngagement:
            start()

        case .callVisualizer:
            start()

        case .unknown(let type):
            debugPrint("Unknown engagement started (type='\(type)').")

        @unknown default:
            assertionFailure("Unexpected case in 'EngaagementSource' enum.")
        }
    }

    func end(with reason: CoreSdkClient.EngagementEndingReason) {
        switch reason {
        case .visitorHungUp:
            state = .ended(.byVisitor)
        case .operatorHungUp, .followUp:
            // Save engagement ended by operator to fetch a survey
            endedEngagement = environment.coreSdk.getCurrentEngagement()
            state = .ended(.byOperator)
        case .error:
            state = .ended(.byError)
        @unknown default:
            state = .ended(.byError)
        }
    }

    func fail(error: CoreSdkClient.SalemoveError) {
        // Fail is called from CoreSDK when acces token expiration happens
        // and it leads to fetchQueues failure that stops queues observing
        // Also when token expires CoreSDK makes force deauthentication which
        // allows to refetch the queues without errors
        environment.queuesMonitor.fetchAndMonitorQueues(queuesIds: queueIds ?? [])
        notify(.error(error))
    }
}

extension InteractorState: Equatable {
    static func == (lhs: InteractorState, rhs: InteractorState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.enqueueing, .enqueueing),
             (.enqueued, .enqueued):
            return true

        case (.ended(let lhsReason), .ended(let rhsReason)):
            return lhsReason == rhsReason

        case (.engaged(let lhsOperator), .engaged(let rhsOperator)):
            return lhsOperator == rhsOperator

        default:
            return false
        }
    }
}

#if DEBUG
extension Interactor {
    func setCurrentEngagement(_ engagement: CoreSdkClient.Engagement?) {
        currentEngagement = engagement
    }

    func setEndedEngagement(_ engagement: CoreSdkClient.Engagement?) {
        endedEngagement = engagement
    }
}
#endif
