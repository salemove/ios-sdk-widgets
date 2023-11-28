import Foundation

enum InteractorState {
    case none
    case enqueueing(CoreSdkClient.MediaType)
    case enqueued(CoreSdkClient.QueueTicket)
    case engaged(CoreSdkClient.Operator?)
    case ended(EndEngagementReason)
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
    case onEngagementRequest(Command<Bool>)
}

class Interactor {
    typealias EventHandler = (InteractorEvent) -> Void

    let queueIds: [String]
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
    var currentEngagement: CoreSdkClient.Engagement?

    private var observers = [() -> (AnyObject?, EventHandler)]()

    var state: InteractorState = .none {
        didSet {
            if oldValue != state {
                notify(.stateChanged(state))
            }
        }
    }
    var environment: Environment

    init(
        visitorContext: Configuration.VisitorContext?,
        queueIds: [String],
        environment: Environment
    ) {
        self.queueIds = queueIds
        self.visitorContext = visitorContext
        self.environment = environment
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

                environment.gcd.mainQueue.asyncIfNeeded {
                    handler(event)
                }
            }
    }
}

extension Interactor {
    func enqueueForEngagement(
        mediaType: CoreSdkClient.MediaType,
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        state = .enqueueing

        switch mediaType {
        case .text:
             environment.log.prefixed(Self.self).info("Start queueing for chat engagement")
        case .audio, .video:
            environment.log.prefixed(Self.self).info("Start queueing for media engagement")
        case .unknown, .phone, .messaging:
            break
        @unknown default:
            break
        }

        let options = mediaType == .audio || mediaType == .video
        ? CoreSdkClient.EngagementOptions(mediaDirection: .twoWay)
        : nil

        let coreSdkVisitorContext: CoreSdkClient.VisitorContext? = (self.visitorContext?.assetId)
            .map(CoreSdkClient.VisitorContext.AssetId.init(rawValue:))
            .map(CoreSdkClient.VisitorContext.ContextType.assetId)
            .map(CoreSdkClient.VisitorContext.init(_:))

        self.environment.coreSdk.queueForEngagement(
            .init(
                queueIds: self.queueIds,
                visitorContext: coreSdkVisitorContext,
                // shouldCloseAllQueues is `true` by default core sdk,
                // here it is passed explicitly
                shouldCloseAllQueues: true,
                mediaType: mediaType,
                engagementOptions: options
            )
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.environment.log.prefixed(Self.self).info("Queue for engagement stopped due to error or empty queue")
                self?.state = .ended(.byError)
                failure(error)
            case .success(let ticket):

                if case .enqueueing = self?.state {
                    self?.state = .enqueued(ticket)
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

    func endSession(
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        switch state {
        case .none:
            success()
        case .enqueueing:
            state = .ended(.byVisitor)
            success()
        case .enqueued(let ticket):
            exitQueue(
                ticket: ticket,
                success: success,
                failure: failure
            )
        case .engaged:
            endEngagement(
                success: success,
                failure: failure
            )
        case .ended(let reason):
            state = .ended(reason)
            success()
        }
    }

    func exitQueue(
        ticket: CoreSdkClient.QueueTicket,
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        environment.log.prefixed(Self.self).info("Cancel queue ticket")
        environment.coreSdk.cancelQueueTicket(ticket) { [weak self] _, error in
            if let error = error {
                failure(error)
            } else {
                self?.state = .ended(.byVisitor)
                success()
            }
        }
    }

    func endEngagement(
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        environment.coreSdk.endEngagement { [weak self] _, error in
            if let error = error {
                failure(error)
            } else {
                self?.state = .ended(.byVisitor)
                success()
            }
        }
    }
}

extension Interactor: CoreSdkClient.Interactable {
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
        return { [weak self] answer in
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
            self?.notify(.onEngagementRequest(action))
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
            if let stream = stream {
                self?.notify(.audioStreamAdded(stream))
            } else if let error = error {
                self?.notify(.audioStreamError(error))
            }
        }
    }

    var onVideoStreamAdded: CoreSdkClient.VideoStreamAddedBlock {
        return { [weak self] stream, error in
            if let stream = stream {
                self?.notify(.videoStreamAdded(stream))
            } else if let error = error {
                self?.notify(.videoStreamError(error))
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
        currentEngagement = environment.coreSdk.getCurrentEngagement()
        switch reason {
        case .visitorHungUp:
            state = .ended(.byVisitor)
        case .operatorHungUp:
            state = .ended(.byOperator)
        case .error:
            state = .ended(.byError)
        @unknown default:
            state = .ended(.byError)
        }
    }

    func fail(error: CoreSdkClient.SalemoveError) {
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
