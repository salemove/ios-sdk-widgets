import SalemoveSDK

class CallViewModel: EngagementViewModel, ViewModel {
    enum Event {
        case viewDidLoad
        case chatTapped
    }

    enum Action {
        case queueWaiting
        case queueConnecting
        case queueConnected(name: String?, imageUrl: String?)
    }

    enum DelegateEvent {
        case chat
    }

    enum CallKind {
        case audio
        case video
    }

    enum StartAction {
        case `default`
        case startAudio(AnswerWithSuccessBlock)
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private var callKind: CallKind
    private let startAction: StartAction

    init(interactor: Interactor,
         alertConf: AlertConf,
         callKind: CallKind,
         startAction: StartAction) {
        self.callKind = callKind
        self.startAction = startAction
        super.init(interactor: interactor, alertConf: alertConf)
    }

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
        case .chatTapped:
            delegate?(.chat)
        }
    }

    private func start() {
        switch startAction {
        case .default:
            enqueue()
        case .startAudio(let answer):
            answer(true, nil)
            // show connecting
            // wait for audio connected event
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .stateChanged(let state):
            switch state {
            case .inactive:
                break
            case .enqueueing:
                action?(.queueWaiting)
            case .enqueued:
                break // request audio/video
            case .engaged(let engagedOperator):
                let name = engagedOperator?.firstName
                let pictureUrl = engagedOperator?.picture?.url
                //action?(.queueConnected(name: name, imageUrl: pictureUrl))
                //action?(.showEndButton)
                //delegate?(.operatorImage(url: engagedOperator?.picture?.url))
            }
        default:
            break
        }
    }
}
