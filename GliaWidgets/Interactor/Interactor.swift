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
    case engagementTransferred(CoreSdkClient.Operator?)
    case engagementTransferring
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

    var currentEngagement: CoreSdkClient.Engagement?

    /// Flag indicating if configuration was already performed.
    var isConfigurationPerformed: Bool = false

    private let visitorContext: CoreSdkClient.VisitorContext
    private var observers = [() -> (AnyObject?, EventHandler)]()
    private var isEngagementEndedByVisitor = false
    private let sdkConfiguration: CoreSdkClient.Salemove.Configuration
    private(set) var state: InteractorState = .none {
        didSet {
            if oldValue != state {
                notify(.stateChanged(state))
            }
        }
    }
    private var environment: Environment

    init(
        with conf: CoreSdkClient.Salemove.Configuration,
        queueID: String,
        visitorContext: CoreSdkClient.VisitorContext,
        environment: Environment
    ) {
        self.queueID = queueID
        self.visitorContext = visitorContext
        self.sdkConfiguration = conf
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

    func withConfiguration(_ action: @escaping () -> Void) {
        environment.coreSdk.configureWithInteractor(self)
        // Perform configuration only if it was not done previously.
        // Otherwise side effects may occur. For example `onHold` callback
        // stops being triggered for audio stream.
        if isConfigurationPerformed {
            // Early out if configuration is already performed. 
            action()
        } else {
            // Mark configuration applied and perfrom configuration.
            isConfigurationPerformed = true
            environment.coreSdk.configureWithConfiguration(sdkConfiguration) {
                action()
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

        let options = mediaType == .audio || mediaType == .video
        ? CoreSdkClient.EngagementOptions(mediaDirection: .twoWay)
            : nil

        withConfiguration { [weak self] in
            guard let self = self else { return }
            self.environment.coreSdk.queueForEngagement(
                self.queueID,
                self.visitorContext,
                // shouldCloseAllQueues is `true` by default core sdk,
                // here it is passed explicitly
                true,
                mediaType,
                options
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
    }

    func request(
        _ media: CoreSdkClient.MediaType,
        direction: CoreSdkClient.MediaDirection,
        success: @escaping () -> Void,
        failure: @escaping (Error?, CoreSdkClient.SalemoveError?) -> Void
    ) {
        withConfiguration { [weak self] in
            do {
                let offer = try CoreSdkClient.MediaUpgradeOffer(
                    type: media,
                    direction: direction
                )
                self?.environment.coreSdk.requestMediaUpgradeWithOffer(offer) { isSuccess, error in
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
    }

    func sendMessagePreview(_ message: String) {
        environment.coreSdk.sendMessagePreview(message) { _, _ in }
    }

    func send(
        _ message: String,
        attachment: CoreSdkClient.Attachment?,
        success: @escaping (CoreSdkClient.Message) -> Void,
        failure: @escaping (CoreSdkClient.SalemoveError) -> Void
    ) {
        withConfiguration { [weak self] in
            self?.environment.coreSdk.sendMessageWithAttachment(
                message,
                attachment
            ) { message, error in
                if let error = error {
                    failure(error)
                } else if let message = message {
                    success(message)
                }
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
        environment.coreSdk.cancelQueueTicket(ticket) { [weak self] _, error in
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
        environment.coreSdk.endEngagement { _, error in
            if let error = error {
                failure(error)
            } else {
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
        return { [weak self] operators in
            let engagedOperator = operators?.first

            self?.state = .engaged(engagedOperator)
            self?.notify(.engagementTransferred(engagedOperator))
        }
    }

    var onEngagementTransferring: CoreSdkClient.EngagementTransferringBlock {
        return { [weak self] in
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

    func end() {

        currentEngagement = environment.coreSdk.getCurrentEngagement()
        state = isEngagementEndedByVisitor == true ? .ended(.byVisitor) : .ended(.byOperator)
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
             (.enqueued, .enqueued),
             (.ended, .ended):
            return true

        case (.engaged(let lhsOperator), .engaged(let rhsOperator)):
            return lhsOperator == rhsOperator

        default:
            return false
        }
    }
}
