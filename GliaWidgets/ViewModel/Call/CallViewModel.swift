import SalemoveSDK

class CallViewModel: EngagementViewModel, ViewModel {
    private typealias Strings = L10n.Call

    enum Button {
        case chat
        case video
        case mute
        case speaker
        case minimize
    }

    enum Event {
        case viewDidLoad
        case buttonTapped(Button)
    }

    enum Action {
        case queue
        case connecting(name: String?, imageUrl: String?)
        case connected(name: String?, imageUrl: String?)
        case setCallDurationText(String)
        case setTitle(String)
        case setInfoTextVisible(Bool)
        case showButtons([Button])
        case setButton(Button, enabled: Bool)
    }

    enum DelegateEvent {
        case chat
        case minimize
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
    private let durationCounter = CallDurationCounter()

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
        case .buttonTapped(let button):
            buttonTapped(button)
        }
    }

    override func start() {
        super.start()
        update(for: callKind)
        updateButtons()

        switch startAction {
        case .default:
            enqueue()
        case .startAudio(let answer):
            answer(true, nil)
            action?(.connecting(name: interactor.engagedOperator?.firstName,
                                imageUrl: interactor.engagedOperator?.picture?.url))
            action?(.setInfoTextVisible(true))
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)
        updateButtons()

        switch state {
        case .enqueueing:
            action?(.queue)
            action?(.setInfoTextVisible(true))
        case .engaged:
            switch startAction {
            case .default:
                requestMedia()
            default:
                break
            }
        case .inactive:
            durationCounter.stop()
        default:
            break
        }
    }

    private func update(for callKind: CallKind) {
        switch callKind {
        case .audio:
            action?(.setTitle(Strings.Audio.title))
            action?(.showButtons([.chat, .mute, .speaker, .minimize]))
        case .video:
            action?(.setTitle(Strings.Video.title))
            action?(.showButtons([.chat, .video, .mute, .speaker, .minimize]))
        }
    }

    private func update(for audioState: AudioState) {
        switch audioState {
        case .twoWay:
            durationCounter.start(onUpdate: updatedCallDuration)
            action?(.connected(name: interactor.engagedOperator?.firstName,
                               imageUrl: interactor.engagedOperator?.picture?.url))
            action?(.setInfoTextVisible(false))
        default:
            break
        }
    }

    private func updateButtons() {
        let chatEnabled = interactor.isEngaged
        let videoEnabled = false
        let muteEnabled = false
        let speakerEnabled = false
        let minimizeEnabled = true
        action?(.setButton(.chat, enabled: chatEnabled))
        action?(.setButton(.video, enabled: videoEnabled))
        action?(.setButton(.mute, enabled: muteEnabled))
        action?(.setButton(.speaker, enabled: speakerEnabled))
        action?(.setButton(.minimize, enabled: minimizeEnabled))
    }

    private func buttonTapped(_ button: Button) {
        switch button {
        case .chat:
            delegate?(.chat)
        case .video:
            break
        case .mute:
            break
        case .speaker:
            break
        case .minimize:
            delegate?(.minimize)
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

    private func updatedCallDuration(_ duration: Int) {
        let text = Strings.Connect.Connected.secondText.withCallDuration(duration.asDurationString)
        action?(.setCallDurationText(text))
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .audioStreamAdded(let stream):
            updateAudioState(with: stream)
        case .audioStreamError(let error):
            showAlert(for: error)
        default:
            break
        }
    }
}
