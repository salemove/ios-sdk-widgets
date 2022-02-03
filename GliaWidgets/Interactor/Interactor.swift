import Foundation

enum InteractorState {
    case none
    case enqueueing
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
    case audioStreamAdded(CoreSdkClient.AudioStreamable)
    case audioStreamError(CoreSdkClient.SalemoveError)
    case videoStreamAdded(CoreSdkClient.VideoStreamable)
    case videoStreamError(CoreSdkClient.SalemoveError)
    case screenShareOffer(answer: CoreSdkClient.AnswerBlock)
    case screenShareError(error: CoreSdkClient.SalemoveError)
    case screenSharingStateChanged(to: CoreSdkClient.VisitorScreenSharingState)
    case error(CoreSdkClient.SalemoveError)
}

class Interactor {
    typealias EventHandler = (InteractorEvent) -> Void

    let queueID: String
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

    private let visitorContext: CoreSdkClient.VisitorContext
    private var observers = [() -> (AnyObject?, EventHandler)]()
    private var isEngagementEndedByVisitor = false
    private(set) var state: InteractorState = .none {
        didSet {
            if oldValue != state {
                notify(.stateChanged(state))
            }
        }
    }

    init(
        with conf: CoreSdkClient.Salemove.Configuration,
        queueID: String,
        visitorContext: CoreSdkClient.VisitorContext
    ) {
        self.queueID = queueID
        self.visitorContext = visitorContext
        configure(with: conf)
    }

    func addObserver(_ observer: AnyObject, handler: @escaping EventHandler) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append { [weak observer] in (observer, handler) }
    }

    func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
    }

    private func configure(with conf: CoreSdkClient.Salemove.Configuration) {
        CoreSdkClient.Salemove.sharedInstance.configure(with: conf) {
            // SDK is initialized and ready to use.
        }
        CoreSdkClient.Salemove.sharedInstance.configure(interactor: self)
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
        mediaType: CoreSdkClient.MediaType,
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        state = .enqueueing

        var options: CoreSdkClient.EngagementOptions? = nil

        if mediaType == .audio || mediaType == .video {
            options = .init(mediaDirection: .twoWay)
        }

        CoreSdkClient.Salemove.sharedInstance.queueForEngagement(
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
        _ media: CoreSdkClient.MediaType,
        direction: CoreSdkClient.MediaDirection,
        success: @escaping () -> Void,
        failure: @escaping (Error?, CoreSdkClient.SalemoveError?) -> Void
    ) {
        do {
            let offer = try CoreSdkClient.MediaUpgradeOffer(type: media, direction: direction)
            CoreSdkClient.Salemove.sharedInstance.requestMediaUpgrade(
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
        CoreSdkClient.Salemove.sharedInstance.sendMessagePreview(message: message) { _, _ in }
    }

    func send(
        _ message: String,
        attachment: CoreSdkClient.Attachment?,
        success: @escaping (CoreSdkClient.Message) -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        CoreSdkClient.Salemove.sharedInstance.send(
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
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
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
        ticket: CoreSdkClient.QueueTicket,
        success: @escaping () -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        CoreSdkClient.Salemove.sharedInstance.cancel(
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
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        CoreSdkClient.Salemove.sharedInstance.endEngagement { [weak self] _, error in
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

    var onEngagementRequest: CoreSdkClient.RequestOfferBlock {
        return { answer in
            let context = CoreSdkClient.VisitorContext(type: .page, url: "wwww.example.com")
            answer(context, true) { _, _ in }
        }
    }

    var onEngagementTransfer: CoreSdkClient.EngagementTransferBlock {
        return { _ in }
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
        CoreSdkClient.Salemove.sharedInstance.requestEngagedOperator { [weak self] operators, _ in
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

    func fail(error: CoreSdkClient.SalemoveError) {
        notify(.error(error))
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
