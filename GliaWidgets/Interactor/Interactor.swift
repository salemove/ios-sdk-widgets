import SalemoveSDK

enum QueueStatus {
    case none
    case enqueued(QueueTicket)
    case queueExited
}

enum InteractorEvent {
    case failedToEnqueue(SalemoveError)
    case queueStatusChanged(QueueStatus)
    case failedToExitQueue(SalemoveError)
    case error(SalemoveError)
}

class Interactor {
    typealias EventHandler = (InteractorEvent) -> Void

    private let queueID: String
    private let visitorContext: SalemoveSDK.VisitorContext
    private var observers = [()->(AnyObject?, EventHandler)]()
    private var queueStatus: QueueStatus = .none {
        didSet { notify(.queueStatusChanged(queueStatus)) }
    }

    init(with conf: Configuration,
         queueID: String,
         visitorContext: VisitorContext) throws {
        self.queueID = queueID
        self.visitorContext = visitorContext.apiContext
        try configure(with: conf)
    }

    private func configure(with conf: Configuration) throws {
        try Salemove.sharedInstance.configure(appToken: conf.appToken)
        try Salemove.sharedInstance.configure(apiToken: conf.apiToken)
        try Salemove.sharedInstance.configure(environment: conf.environment.url)
        try Salemove.sharedInstance.configure(site: conf.site)
        Salemove.sharedInstance.configure(interactor: self)
    }

    func addObserver(_ observer: AnyObject, handler: @escaping EventHandler) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append({ [weak observer] in (observer, handler) })
    }

    func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
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

    func enqueueForEngagement() {
        Salemove.sharedInstance.queueForEngagement(queueID: queueID,
                                                   visitorContext: visitorContext) { queueTicket, error in
            if let error = error {
                self.notify(.failedToEnqueue(error))
            } else if let ticket = queueTicket {
                self.queueStatus = .enqueued(ticket)
            }
            print(queueTicket, error?.reason)
        }
    }

    func exitEngagementQueue() {
        switch queueStatus {
        case .enqueued(let ticket):
            Salemove.sharedInstance.cancel(queueTicket: ticket) { _, error in
                if let error = error {
                    self.notify(.failedToExitQueue(error))
                } else {
                    self.queueStatus = .queueExited
                }
            }
        default:
            break
        }
    }
}

extension Interactor: Interactable {
    var onScreenSharingOffer: ScreenshareOfferBlock {
        print("Called: \(#function)")
        // When the operator asks for sharing the screen, supply the answer
        return { [unowned self] answer in
            //self.showRequestingView(request: "Possibility to share screen", answer: answer)
        }
    }

    var onMediaUpgradeOffer: MediaUgradeOfferBlock {
        print("Called: \(#function)")
        // When the operator asks for audio/video, supply the answer
        return { [unowned self] _, answer in
            //self.showRequestingView(request: "Posibility to enable media", answer: answer)
        }
    }

    var onEngagementRequest: RequestOfferBlock {
        print("Called: \(#function)")
        // Handle the incoming engagement request
        return { answer in
        // Supply the context that will be shown in the CoBrowsing area
            let context = SalemoveSDK.VisitorContext(type: .page, url: "wwww.example.com")
            answer(context, true) {_, _ in }
        }
    }

    var onOperatorTypingStatusUpdate: OperatorTypingStatusUpdate {
        print("Called: \(#function)")
        // Handle the operator typing status during an engagement
        return { _ in

        }
    }

    var onMessagesUpdated: MessagesUpdateBlock {
        print("Called: \(#function)")
        // Handle the incoming messages list
        return { [unowned self] messages in

        }
    }

    var onVisitorScreenSharingStateChange: VisitorScreenSharingStateChange {
        print("Called: \(#function)")
         // Handle the screen sharing state
        return { [unowned self] state, error in
            if let error = error {
                // Show or log the error
            } else {
                // Update the view by showing the stream
                DispatchQueue.main.async {
                }
            }
        }
    }

    var onAudioStreamAdded: AudioStreamAddedBlock {
        print("Called: \(#function)")
        // Handle the incoming audio stream block
        return { [unowned self] stream, error in
            if let stream = stream {
                // Update the view by showing the stream
                DispatchQueue.main.async {

                }
            } else if let error = error {
                // Show or log the error
            }
        }
    }

    var onVideoStreamAdded: VideoStreamAddedBlock {
        print("Called: \(#function)")
         // Handle the incoming video stream block
        return { [unowned self] stream, error in
            if let stream = stream {
                // Update the view by showing the stream
                DispatchQueue.main.async {

                }
            } else if let error = error {
                // Show or log the error
            }
        }
    }

    func start() {
        print("Called: \(#function)")
        // Remove any spinners or activity indicators and proceed with the flow
        //endLoading()
    }

    func end() {
        print("Called: \(#function)")
        // Remove any active sessions and do a cleanup and maybe dismiss the controller
        //cleanup()
    }

    func fail(with reason: String?) {
        print("Called: \(#function)")
        // Handle the failing engagement request and maybe log the reason or show it to the user
        if let reason = reason {
            print(reason)
        }
        //cleanup()
    }

    func receive(message: Message) {
        print("Called: \(#function)")
        // Update the messages that are coming from the SDK and show them to to the user
        print("MESSAGE:", message.content)
    }

    func fail(error: SalemoveError) {
        print("Called: \(#function)")
        print(error)
    }
}
