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
        case hideConnect
        case setTitle(String)
        case setOperatorImage(url: String?)
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

    private enum AudioState {
        case none
        case remote(AudioStreamable)
        case local(AudioStreamable)
        case twoWay(local: AudioStreamable, remote: AudioStreamable)
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private var callKind: CallKind {
        didSet { update(for: callKind) }
    }
    private var audioState: AudioState = .none {
        didSet { update(for: audioState) }
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
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            action?(.queue)
        case .engaged:
            switch startAction {
            case .default:
                requestMedia()
            default:
                break
            }
        default:
            break
        }
    }

    private func update(for callKind: CallKind) {
        switch callKind {
        case .audio:
            action?(.setTitle(Strings.Audio.title))
        case .video:
            action?(.setTitle(Strings.Video.title))
        }
    }

    private func update(for audioState: AudioState) {
        switch audioState {
        case .twoWay:
            action?(.hideConnect)
            action?(.setOperatorImage(url: interactor.engagedOperator?.picture?.url))
        default:
            break
        }
    }

    private func requestMedia() {
        let name = interactor.engagedOperator?.firstName
        let imageUrl = interactor.engagedOperator?.picture?.url
        action?(.connecting(name: name, imageUrl: imageUrl))

        let mediaType: MediaType = {
            switch callKind {
            case .audio:
                return .audio
            case .video:
                return .video
            }
        }()

        interactor.request(mediaType) {

        } failure: { [weak self] error, salemoveError in
            self?.action?(.hideConnect)
            if let error = error {
                self?.showAlert(for: error)
            } else if let error = salemoveError {
                self?.showAlert(for: error)
            }
        }
    }

    private func updateAudioState(with stream: AudioStreamable) {
        if stream.isRemote {
            switch audioState {
            case .none:
                audioState = .remote(stream)
            case .remote:
                audioState = .remote(stream)
            case .local(let local):
                audioState = .twoWay(local: local, remote: stream)
            case .twoWay(local: let local, remote: _):
                audioState = .twoWay(local: local, remote: stream)
            }
        } else {
            switch audioState {
            case .none:
                audioState = .local(stream)
            case .remote(let remote):
                audioState = .twoWay(local: stream, remote: remote)
            case .local:
                audioState = .local(stream)
            case .twoWay(local: _, remote: let remote):
                audioState = .twoWay(local: stream, remote: remote)
            }
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .audioStreamAdded(let stream):
            updateAudioState(with: stream)
        case .audioStreamError(let error):
            action?(.hideConnect)
            showAlert(for: error)
        default:
            break
        }
    }
}
