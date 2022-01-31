import SalemoveSDK

enum InteractorState {
    case none
    case enqueueing
    case enqueued(QueueTicket)
    case engaged(Operator?)
    case ended(EndEngagementReason)
}

enum EndEngagementReason {
    case byOperator
    case byVisitor
    case byError
}

enum InteractorEvent {
    case stateChanged(InteractorState)
    case receivedMessage(Message)
    case messagesUpdated([Message])
    case typingStatusUpdated(OperatorTypingStatus)
    case upgradeOffer(MediaUpgradeOffer, answer: AnswerWithSuccessBlock)
    case audioStreamAdded(AudioStreamable)
    case audioStreamError(SalemoveError)
    case videoStreamAdded(VideoStreamable)
    case videoStreamError(SalemoveError)
    case screenShareOffer(answer: AnswerBlock)
    case screenShareError(error: SalemoveError)
    case screenSharingStateChanged(to: VisitorScreenSharingState)
    case error(SalemoveError)
}

class Interactor {
    let queueID: String
    var engagedOperator: Operator? {
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

    var event: Observable<InteractorEvent> {
        eventSubject
    }

    private let visitorContext: VisitorContext
    private var isEngagementEndedByVisitor = false
    private let eventSubject = PublishSubject<InteractorEvent>()

    private(set) var state: InteractorState = .none {
        didSet {
            if oldValue != state {
                eventSubject.send(.stateChanged(state))
            }
        }
    }

    init(
        with conf: Salemove.Configuration,
        queueID: String,
        visitorContext: VisitorContext
    ) {
        self.queueID = queueID
        self.visitorContext = visitorContext
        configure(with: conf)
    }

    private func configure(with conf: Salemove.Configuration) {
        Salemove.sharedInstance.configure(with: conf) {
            // SDK is initialized and ready to use.
        }
        Salemove.sharedInstance.configure(interactor: self)
    }
}

extension Interactor {
    func enqueueForEngagement(
        mediaType: MediaType,
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        state = .enqueueing

        var options: EngagementOptions?

        if mediaType == .audio || mediaType == .video {
            options = .init(mediaDirection: .twoWay)
        }

        Salemove.sharedInstance.queueForEngagement(
            queueID: queueID,
            visitorContext: visitorContext,
            mediaType: mediaType,
            options: options
        ) { [weak self] queueTicket, error in
            if let error = error {
                self?.state = .ended(.byError)
                failure(error)
            } else if let ticket = queueTicket {
                if case .enqueueing = self?.state {
                    self?.state = .enqueued(ticket)
                }
                success()
            }
        }
    }

    func request(
        _ media: MediaType,
        direction: MediaDirection,
        success: @escaping () -> Void,
        failure: @escaping (Error?, SalemoveError?) -> Void
    ) {
        do {
            let offer = try MediaUpgradeOffer(type: media, direction: direction)
            Salemove.sharedInstance.requestMediaUpgrade(
                offer: offer
            ) { isSuccess, error in
                if let error = error {
                    failure(nil, error)
                } else if !isSuccess {
                    failure(nil, nil)
                } else {
                    success()
                }
            }
        } catch {
            failure(error, nil)
        }
    }

    func sendMessagePreview(_ message: String) {
        Salemove.sharedInstance.sendMessagePreview(message: message) { _, _ in }
    }

    func send(
        _ message: String,
        attachment: Attachment?,
        success: @escaping (Message) -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        Salemove.sharedInstance.send(
            message: message,
            attachment: attachment
        ) { message, error in
            if let error = error {
                failure(error)
            } else if let message = message {
                success(message)
            }
        }
    }

    func endSession(
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        isEngagementEndedByVisitor = true

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

    private func exitQueue(
        ticket: QueueTicket,
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        Salemove.sharedInstance.cancel(
            queueTicket: ticket
        ) { [weak self] _, error in
            if let error = error {
                failure(error)
            } else {
                self?.state = .ended(.byVisitor)
                success()
            }
        }
    }

    private func endEngagement(
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        Salemove.sharedInstance.endEngagement { [weak self] _, error in
            if let error = error {
                failure(error)
            } else {
                self?.state = .ended(.byVisitor)
                success()
            }
        }
    }
}

extension Interactor: Interactable {
    var onScreenSharingOffer: ScreenshareOfferBlock {
        return { [weak self] answer in
            self?.eventSubject.send(.screenShareOffer(answer: answer))
        }
    }

    var onMediaUpgradeOffer: MediaUgradeOfferBlock {
        return { [weak self] offer, answer in
            self?.eventSubject.send(.upgradeOffer(offer, answer: answer))
        }
    }

    var onEngagementRequest: RequestOfferBlock {
        return { answer in
            let context = SalemoveSDK.VisitorContext(type: .page, url: "wwww.example.com")
            answer(context, true) { _, _ in }
        }
    }

    var onEngagementTransfer: EngagementTransferBlock {
        return { _ in }
    }

    var onOperatorTypingStatusUpdate: OperatorTypingStatusUpdate {
        return { [weak self] operatorTypingStatus in
            self?.eventSubject.send(.typingStatusUpdated(operatorTypingStatus))
        }
    }

    var onMessagesUpdated: MessagesUpdateBlock {
        return { [weak self] messages in
            self?.eventSubject.send(.messagesUpdated(messages))
        }
    }

    var onVisitorScreenSharingStateChange: VisitorScreenSharingStateChange {
        return { [weak self] state, error in
            if let error = error {
                self?.eventSubject.send(.screenShareError(error: error))
            } else {
                self?.eventSubject.send(.screenSharingStateChanged(to: state))
            }
        }
    }

    var onAudioStreamAdded: AudioStreamAddedBlock {
        return { [weak self] stream, error in
            if let stream = stream {
                self?.eventSubject.send(.audioStreamAdded(stream))
            } else if let error = error {
                self?.eventSubject.send(.audioStreamError(error))
            }
        }
    }

    var onVideoStreamAdded: VideoStreamAddedBlock {
        return { [weak self] stream, error in
            if let stream = stream {
                self?.eventSubject.send(.videoStreamAdded(stream))
            } else if let error = error {
                self?.eventSubject.send(.videoStreamError(error))
            }
        }
    }

    func receive(message: Message) {
        eventSubject.send(.receivedMessage(message))
    }

    func start() {
        Salemove.sharedInstance.requestEngagedOperator { [weak self] operators, _ in
            let engagedOperator = operators?.first
            self?.state = .engaged(engagedOperator)
        }
    }

    func end() {
        if isEngagementEndedByVisitor {
            state = .ended(.byVisitor)
        } else {
            state = .ended(.byOperator)
        }
    }

    func fail(error: SalemoveError) {
        eventSubject.send(.error(error))
    }
}

extension InteractorState: Equatable {
    static func == (lhs: InteractorState, rhs: InteractorState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.enqueueing, .enqueueing),
             (.engaged, .engaged),
             (.enqueued, .enqueued),
             (.ended, .ended):
            return true
        default:
            return false
        }
    }
}
