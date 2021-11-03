import SalemoveSDK

enum InteractorState {
    case none
    case enqueueing
    case enqueued(QueueTicket)
    case engaged(Operator?)
    case ended
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
    typealias EventHandler = (InteractorEvent) -> Void

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

    private let visitorContext: VisitorContext
    private var observers = [() -> (AnyObject?, EventHandler)]()
    private(set) var state: InteractorState = .none {
        didSet { notify(.stateChanged(state)) }
    }

    init(
        with conf: Configuration,
        queueID: String,
        visitorContext: VisitorContext
    ) throws {
        self.queueID = queueID
        self.visitorContext = visitorContext
        try configure(with: conf)
    }

    func addObserver(_ observer: AnyObject, handler: @escaping EventHandler) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append { [weak observer] in (observer, handler) }
    }

    func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
    }

    private func configure(with conf: Configuration) throws {
        try Salemove.sharedInstance.configure(appToken: conf.appToken)
        try Salemove.sharedInstance.configure(environment: conf.environment.url)
        try Salemove.sharedInstance.configure(site: conf.site)
        Salemove.sharedInstance.configure(interactor: self)
    }

    private func notify(_ event: InteractorEvent) {
        observers
            .compactMap { $0() }
            .filter { $0.0 != nil }
            .forEach {
                let handler = $0.1
                DispatchQueue.main.async {
                    handler(event)
                }
            }
    }
}

extension Interactor {
    func enqueueForEngagement(
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        print("Called: \(#function)")
        state = .enqueueing
        Salemove.sharedInstance.queueForEngagement(
            queueID: queueID,
            visitorContext: visitorContext
        ) { [weak self] queueTicket, error in
            if let error = error {
                self?.state = .ended
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
        print("Called: \(#function)")
        switch state {
        case .none, .ended:
            success()
        case .enqueueing:
            state = .ended
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
        }
    }

    private func exitQueue(
        ticket: QueueTicket,
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        print("Called: \(#function)")
        Salemove.sharedInstance.cancel(
            queueTicket: ticket
        ) { [weak self] _, error in
            if let error = error {
                failure(error)
            } else {
                self?.state = .ended
                success()
            }
        }
    }

    private func endEngagement(
        success: @escaping () -> Void,
        failure: @escaping (SalemoveError) -> Void
    ) {
        print("Called: \(#function)")
        Salemove.sharedInstance.endEngagement { [weak self] _, error in
            if let error = error {
                failure(error)
            } else {
                self?.state = .ended
                success()
            }
        }
    }
}

extension Interactor: Interactable {
    var onScreenSharingOffer: ScreenshareOfferBlock {
        print("Called: \(#function)")
        return { [weak self] answer in
            self?.notify(.screenShareOffer(answer: answer))
        }
    }

    var onMediaUpgradeOffer: MediaUgradeOfferBlock {
        print("Called: \(#function)")
        return { [weak self] offer, answer in
            self?.notify(.upgradeOffer(offer, answer: answer))
        }
    }

    var onEngagementRequest: RequestOfferBlock {
        print("Called: \(#function)")
        return { answer in
            let context = SalemoveSDK.VisitorContext(type: .page, url: "wwww.example.com")
            answer(context, true) { _, _ in }
        }
    }

    var onEngagementTransfer: EngagementTransferBlock {
        return { _ in }
    }

    var onOperatorTypingStatusUpdate: OperatorTypingStatusUpdate {
        print("Called: \(#function)")
        return { [weak self] operatorTypingStatus in
            self?.notify(.typingStatusUpdated(operatorTypingStatus))
        }
    }

    var onMessagesUpdated: MessagesUpdateBlock {
        print("Called: \(#function)")
        return { [weak self] messages in
            self?.notify(.messagesUpdated(messages))
        }
    }

    var onVisitorScreenSharingStateChange: VisitorScreenSharingStateChange {
        print("Called: \(#function)")
        return { [weak self] state, error in
            if let error = error {
                self?.notify(.screenShareError(error: error))
            } else {
                switch state.status {
                case .sharing:
                    print("Screen sharing started")
                case .notSharing:
                    print("Screen sharing stopped")
                @unknown default:
                    break
                }
                self?.notify(.screenSharingStateChanged(to: state))
            }
        }
    }

    var onAudioStreamAdded: AudioStreamAddedBlock {
        print("Called: \(#function)")
        return { [weak self] stream, error in
            if let stream = stream {
                self?.notify(.audioStreamAdded(stream))
            } else if let error = error {
                self?.notify(.audioStreamError(error))
            }
        }
    }

    var onVideoStreamAdded: VideoStreamAddedBlock {
        print("Called: \(#function)")
        return { [weak self] stream, error in
            if let stream = stream {
                self?.notify(.videoStreamAdded(stream))
            } else if let error = error {
                self?.notify(.videoStreamError(error))
            }
        }
    }

    func receive(message: Message) {
        print("Called: \(#function). Content: \(message.content)")
        notify(.receivedMessage(message))
    }

    func start() {
        print("Called: \(#function)")
        Salemove.sharedInstance.requestEngagedOperator { [weak self] operators, _ in
            let engagedOperator = operators?.first
            self?.state = .engaged(engagedOperator)
        }
    }

    func end() {
        print("Called: \(#function)")
        state = .ended
    }

    func fail(error: SalemoveError) {
        print("Called: \(#function)")
        notify(.error(error))
    }
}
