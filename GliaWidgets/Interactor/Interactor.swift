import SalemoveSDK

enum InteractorState {
    case inactive
    case enqueueing
    case enqueued(QueueTicket)
    case engaged(Operator?)
}

enum InteractorEvent {
    case stateChanged(InteractorState)
    case receivedMessage(Message)
    case error(SalemoveError)
}

class Interactor {
    typealias EventHandler = (InteractorEvent) -> Void

    var engagedOperator: Operator? {
        switch state {
        case .engaged(let engagedOperator):
            return engagedOperator
        default:
            return nil
        }
    }

    private let queueID: String
    private let visitorContext: VisitorContext
    private var observers = [() -> (AnyObject?, EventHandler)]()
    private(set) var state: InteractorState = .inactive {
        didSet { notify(.stateChanged(state)) }
    }

    init(with conf: Configuration,
         queueID: String,
         visitorContext: VisitorContext) throws {
        self.queueID = queueID
        self.visitorContext = visitorContext
        try configure(with: conf)
    }

    func addObserver(_ observer: AnyObject, handler: @escaping EventHandler) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append({ [weak observer] in (observer, handler) })
    }

    func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
    }

    private func configure(with conf: Configuration) throws {
        try Salemove.sharedInstance.configure(appToken: conf.appToken)
        try Salemove.sharedInstance.configure(apiToken: conf.apiToken)
        try Salemove.sharedInstance.configure(environment: conf.environment.url)
        try Salemove.sharedInstance.configure(site: conf.site)
        Salemove.sharedInstance.configure(interactor: self)
    }

    private func notify(_ event: InteractorEvent) {
        observers
            .compactMap({ $0() })
            .filter({ $0.0 != nil })
            .forEach({
                let handler = $0.1
                DispatchQueue.main.async {
                    handler(event)
                }
        })
    }
}

extension Interactor {
    func enqueueForEngagement(success: @escaping () -> Void,
                              failure: @escaping (SalemoveError) -> Void) {
        print("Called: \(#function)")
        state = .enqueueing
        Salemove.sharedInstance.queueForEngagement(queueID: queueID,
                                                   visitorContext: visitorContext) { queueTicket, error in
            if let error = error {
                self.state = .inactive
                failure(error)
            } else if let ticket = queueTicket {
                self.state = .enqueued(ticket)
                success()
            }
        }
    }

    func endSession(success: @escaping () -> Void,
                    failure: @escaping (SalemoveError) -> Void) {
        print("Called: \(#function)")
        switch state {
        case .inactive:
            success()
        case .enqueueing:
            self.state = .inactive
            success()
        case .enqueued(let ticket):
            exitQueue(ticket: ticket,
                      success: success,
                      failure: failure)
        case .engaged:
            endEngagement(success: success,
                          failure: failure)
        }
    }

    private func exitQueue(ticket: QueueTicket,
                           success: @escaping () -> Void,
                           failure: @escaping (SalemoveError) -> Void) {
        print("Called: \(#function)")
        Salemove.sharedInstance.cancel(queueTicket: ticket) { _, error in
            if let error = error {
                failure(error)
            } else {
                self.state = .inactive
                success()
            }
        }
    }

    private func endEngagement(success: @escaping () -> Void,
                               failure: @escaping (SalemoveError) -> Void) {
        print("Called: \(#function)")
        Salemove.sharedInstance.endEngagement { _, error in
            if let error = error {
                failure(error)
            } else {
                self.state = .inactive
                success()
            }
        }
    }
}

extension Interactor: Interactable {
    var onScreenSharingOffer: ScreenshareOfferBlock {
        print("Called: \(#function)")
        return { _ in }
    }

    var onMediaUpgradeOffer: MediaUgradeOfferBlock {
        print("Called: \(#function)")
        return { _, _ in }
    }

    var onEngagementRequest: RequestOfferBlock {
        print("Called: \(#function)")
        return { answer in
            let context = SalemoveSDK.VisitorContext(type: .page, url: "wwww.example.com")
            answer(context, true) { _, _ in }
        }
    }

    var onOperatorTypingStatusUpdate: OperatorTypingStatusUpdate {
        print("Called: \(#function)")
        return { _ in }
    }

    var onMessagesUpdated: MessagesUpdateBlock {
        print("Called: \(#function)")
        return { _ in }
    }

    var onVisitorScreenSharingStateChange: VisitorScreenSharingStateChange {
        print("Called: \(#function)")
        return { _, _ in }
    }

    var onAudioStreamAdded: AudioStreamAddedBlock {
        print("Called: \(#function)")
        return { _, _ in }
    }

    var onVideoStreamAdded: VideoStreamAddedBlock {
        print("Called: \(#function)")
        return { _, _ in }
    }

    func start() {
        print("Called: \(#function)")
        Salemove.sharedInstance.requestEngagedOperator { operators, _ in
            let engagedOperator = operators?.first
            self.state = .engaged(engagedOperator)
        }
    }

    func receive(message: Message) {
        print("Called: \(#function)")
        print("MESSAGE:", message.content)
        notify(.receivedMessage(message))
    }

    func end() {
        print("Called: \(#function)")
        state = .inactive
    }

    func fail(error: SalemoveError) {
        print("Called: \(#function)")
        notify(.error(error))
    }
}
