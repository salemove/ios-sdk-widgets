import SalemoveSDK

class CallViewModel: EngagementViewModel, ViewModel {
    private typealias Strings = L10n.Call

    enum Event {
        case viewDidLoad
        case chatTapped
    }

    enum Action {
        case queue
        case connecting(name: String?, imageUrl: String?)
        case removeQueueView
        case setTitle(String)
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

    private var callKind: CallKind {
        didSet { update(for: callKind) }
    }
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

    override func start() {
        super.start()
        update(for: callKind)

        switch startAction {
        case .default:
            enqueue()
        case .startAudio(let answer):
            answer(true, nil)
            action?(.connecting(name: interactor.engagedOperator?.firstName,
                                imageUrl: interactor.engagedOperator?.picture?.url))
            // wait for audio connected event
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            action?(.queue)
        case .engaged:
            requestMediaUpgrade()
        default:
            break
        }
    }

    private func requestMediaUpgrade() {
        let name = interactor.engagedOperator?.firstName
        let imageUrl = interactor.engagedOperator?.picture?.url
        action?(.connecting(name: name, imageUrl: imageUrl))
        // request audio/video
    }

    private func update(for callKind: CallKind) {
        switch callKind {
        case .audio:
            action?(.setTitle(Strings.Audio.title))
        case .video:
            action?(.setTitle(Strings.Video.title))
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        default:
            break
        }
    }
}
