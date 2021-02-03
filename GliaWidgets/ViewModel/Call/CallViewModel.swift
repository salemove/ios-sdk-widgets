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
        case setInfoText(String?)
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

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private var call: Call
    private let startAction: StartAction
    private let durationCounter = CallDurationCounter()

    init(interactor: Interactor,
         alertConf: AlertConf,
         call: Call,
         startAction: StartAction) {
        self.call = call
        self.startAction = startAction
        super.init(interactor: interactor, alertConf: alertConf)
        call.state.addObserver(self) { state, _ in
            self.onStateChanged(state)
        }
        call.audio.addObserver(self) { audio, _ in
            self.onAudioChanged(audio)
        }
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
        update(for: call.kind)
        updateButtons()

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
        updateButtons()

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
        case .inactive:
            call.state.value = .ended
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
            switch call.kind {
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

    private func updateAudio(with stream: AudioStreamable) {
        if stream.isRemote {
            switch call.audio.value {
            case .none:
                call.audio.value = .remote(stream)
            case .remote:
                call.audio.value = .remote(stream)
            case .local(let local):
                call.audio.value = .twoWay(local: local, remote: stream)
            case .twoWay(local: let local, remote: _):
                call.audio.value = .twoWay(local: local, remote: stream)
            }
        } else {
            switch call.audio.value {
            case .none:
                call.audio.value = .local(stream)
            case .remote(let remote):
                call.audio.value = .twoWay(local: stream, remote: remote)
            case .local:
                call.audio.value = .local(stream)
            case .twoWay(local: _, remote: let remote):
                call.audio.value = .twoWay(local: stream, remote: remote)
            }
        }
    }

    private func onStateChanged(_ state: CallState) {
        switch state {
        case .none:
            break
        case .started:
            durationCounter.start { duration in
                self.call.state.value = .progressed(duration: duration)
            }
        case .progressed(duration: let duration):
            let text = Strings.Connect.Connected.secondText.withCallDuration(duration.asDurationString)
            action?(.setCallDurationText(text))
        case .ended:
            break
        }
    }

    private func onAudioChanged(_ audio: CallAudioKind) {
        switch audio {
        case .twoWay:
            call.state.value = .started
            action?(.connected(name: interactor.engagedOperator?.firstName,
                               imageUrl: interactor.engagedOperator?.picture?.url))
            action?(.setInfoText(nil))
        default:
            break
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .audioStreamAdded(let stream):
            updateAudio(with: stream)
        case .audioStreamError(let error):
            showAlert(for: error)
        default:
            break
        }
    }
}
