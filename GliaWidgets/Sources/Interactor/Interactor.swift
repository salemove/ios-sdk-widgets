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

    // Used to save ended engagement to fetch a survey
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
        replaceExisting: Bool
    ) async throws {
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

        let engagementOptions: CoreSdkClient.QueueForEngagementOptions = .init(
            queueIds: queueIds ?? [],
            visitorContext: coreSdkVisitorContext,
            // shouldCloseAllQueues is `true` by default core sdk,
            // here it is passed explicitly
            shouldCloseAllQueues: true,
            mediaType: engagementKind.mediaType,
            engagementOptions: options
        )
        do {
            let ticket = try await environment.coreSdk.queueForEngagement(
                engagementOptions,
                replaceExisting
            )
            if case .enqueueing = state {
                state = .enqueued(ticket, engagementKind)
            }
        } catch {
            self.environment.log.prefixed(Self.self).info("Queue for engagement stopped due to error or empty queue")
            self.state = .ended(.byError)
            throw error
        }
    }

    func sendMessagePreview(_ message: String) async throws -> Bool {
        try await environment.coreSdk.sendMessagePreview(message)
    }

    func send(messagePayload: CoreSdkClient.SendMessagePayload) async throws -> CoreSdkClient.Message {
        try await environment.coreSdk.sendMessageWithMessagePayload(messagePayload)
    }

    @MainActor
    func endSession() async throws {
        switch state {
        case .none:
            break
        case .enqueueing:
            state = .ended(.byVisitor)
        case let .enqueued(ticket, _):
            try await exitQueue(ticket: ticket)
        case .engaged where currentEngagement?.isTransferredSecureConversation == true:
            break
        case .engaged:
            try await endEngagement()
        case .ended:
            // `cleanup` is called once survey fetching is already initiated,
            // so no need to store `endedEngagement` anymore.
            cleanup()
        }
    }

    @MainActor
    func exitQueue(ticket: CoreSdkClient.QueueTicket) async throws {
        environment.log.prefixed(Self.self).info("Cancel queue ticket")
        do {
            _ = try await environment.coreSdk.cancelQueueTicket(ticket)
            state = .ended(.byVisitor)
        } catch {
            throw error
        }
    }

    func endEngagement() async throws {
        _ = try await environment.coreSdk.endEngagement()
        self.state = .ended(.byVisitor)
        self.endedEngagement = environment.coreSdk.getCurrentEngagement()
    }

    /**
        Clean up interactor.
     
        Used to clean up:
        * Cached `endedEngagement` that is used for presenting survey.
        * Interactor `state`.
    */
    func cleanup(_ policy: CleanupPolicy = .clearEndedEngagement) {
        state = .none

        switch policy {
        case .keepEndedEngagement:
            break
        case .clearEndedEngagement:
            endedEngagement = nil
        }
    }
}

// MARK: - Interactable

extension Interactor: CoreSdkClient.Interactable {
    var onEngagementChanged: CoreSdkClient.EngagementChangedBlock {
        return { [weak self] engagement in
            guard let self else { return }

            currentEngagement = engagement

            if let engagement {
                // Save the last non-nil engagement for survey
                endedEngagement = engagement
                return
            }

            // engagement became nil:
            // if we have an ended engagement, keep it for survey; otherwise clear it
            cleanup(endedEngagement != nil ? .keepEndedEngagement : .clearEndedEngagement)
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

    func start() async {
        let operators = try? await environment.coreSdk.requestEngagedOperator()
        let engagedOperator = operators?.first
        state = .engaged(engagedOperator)
        currentEngagement = environment.coreSdk.getCurrentEngagement()
    }

    func start(engagement: CoreSdkClient.Engagement) {
        switch engagement.source {
        case .coreEngagement:
            Task {
               await start()
            }
        case .callVisualizer:
            Task {
                await start()
            }
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
        // Fail is called from CoreSDK when access token expiration happens
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

extension Interactor {
    enum CleanupPolicy {
        /// Reset state but keep `endedEngagement` (for survey flow)
        case keepEndedEngagement
        /// Reset state and clear `endedEngagement`
        case clearEndedEngagement
    }
}
