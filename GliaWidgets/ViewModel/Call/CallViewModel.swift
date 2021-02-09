import SalemoveSDK
import AVFoundation

class CallViewModel: EngagementViewModel, ViewModel {
    private typealias Strings = L10n.Call

    enum Button {
        case chat
        case video
        case mute
        case speaker
        case minimize
    }

    enum ButtonState {
        case active
        case inactive
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
        case setButtonEnabled(Button, enabled: Bool)
        case setButtonState(Button, state: ButtonState)
        case offerMediaUpgrade(SingleMediaUpgradeAlertConfiguration,
                               accepted: () -> Void,
                               declined: () -> Void)
    }

    enum DelegateEvent {
        case chat
        case minimize
    }

    enum StartAction {
        case startEngagement
        case startCall(offer: MediaUpgradeOffer,
                       answer: AnswerWithSuccessBlock)
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let call: Call
    private let startAction: StartAction
    private let durationCounter = CallDurationCounter()
    private var audioPortOverride = AVAudioSession.PortOverride.none

    init(interactor: Interactor,
         alertConfiguration: AlertConfiguration,
         call: Call,
         startAction: StartAction) {
        self.call = call
        self.startAction = startAction
        super.init(interactor: interactor, alertConfiguration: alertConfiguration)
        call.state.addObserver(self) { state, _ in
            self.onStateChanged(state)
        }
        call.video.addObserver(self) { audio, _ in
            self.onVideoChanged(audio)
        }
        call.audio.addObserver(self) { audio, _ in
            self.onAudioChanged(audio)
        }
        call.duration.addObserver(self) { duration, _ in
            self.onDurationChanged(duration)
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
        case .startEngagement:
            enqueue()
        case .startCall(offer: _, answer: let answer):
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
            if case .startEngagement = startAction {
                requestMedia()
            }
        case .inactive:
            call.state.value = .ended
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

    private func updateMediaKind<Streamable>(_ mediaKind: ValueProvider<CallMediaKind<Streamable>>,
                                             with stream: Streamable,
                                             isRemote: Bool) {
        if isRemote {
            switch mediaKind.value {
            case .none, .remote:
                mediaKind.value = .remote(stream)
            case .local(let local):
                mediaKind.value = .twoWay(local: local, remote: stream)
            case .twoWay(local: let local, remote: _):
                mediaKind.value = .twoWay(local: local, remote: stream)
            }
        } else {
            switch mediaKind.value {
            case .none, .local:
                mediaKind.value = .local(stream)
            case .remote(let remote):
                mediaKind.value = .twoWay(local: stream, remote: remote)
            case .twoWay(local: _, remote: let remote):
                mediaKind.value = .twoWay(local: stream, remote: remote)
            }
        }
    }

    private func handleMediaError(_ error: SalemoveError) {
        switch error.error {
        case let mediaError as MediaError:
            switch mediaError {
            case .permissionDenied:
                self.showSettingsAlert(with: alertConfiguration.microphoneSettings)
            default:
                showAlert(for: error)
            }
        default:
            showAlert(for: error)
        }
    }

    private func offerMediaUpgrade(_ offer: MediaUpgradeOffer, answer: @escaping AnswerWithSuccessBlock) {
        switch offer.type {
        case .video:
            offerMediaUpgrade(with: alertConfiguration.videoUpgrade,
                              offer: offer,
                              answer: answer)
        default:
            break
        }
    }

    private func offerMediaUpgrade(with configuration: SingleMediaUpgradeAlertConfiguration,
                                   offer: MediaUpgradeOffer,
                                   answer: @escaping AnswerWithSuccessBlock) {
        guard isViewActive else { return }
        let operatorName = interactor.engagedOperator?.firstName
        action?(.offerMediaUpgrade(configuration.withOperatorName(operatorName),
                                   accepted: { answer(true, nil) },
                                   declined: { answer(false, nil) }))
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .audioStreamAdded(let stream):
            updateMediaKind(call.audio, with: stream, isRemote: stream.isRemote)
        case .videoStreamAdded(let stream):
            updateMediaKind(call.video, with: stream, isRemote: stream.isRemote)
        case .audioStreamError(let error):
            handleMediaError(error)
        case .videoStreamError(let error):
            handleMediaError(error)
        case .upgradeOffer(let offer, answer: let answer):
            offerMediaUpgrade(offer, answer: answer)
        default:
            break
        }
    }
}

extension CallViewModel {
    private func onStateChanged(_ state: CallState) {
        switch state {
        case .none:
            break
        case .started:
            durationCounter.start { duration in
                self.call.duration.value = duration
            }
        case .ended:
            durationCounter.stop()
        }
        updateButtons()
    }

    private func onAudioChanged(_ audio: CallMediaKind<AudioStreamable>) {
        switch audio {
        case .twoWay:
            //TODO
            call.state.value = .started
            action?(.connected(name: interactor.engagedOperator?.firstName,
                               imageUrl: interactor.engagedOperator?.picture?.url))
            action?(.setInfoText(nil))
        default:
            break
        }
        updateButtons()
    }

    private func onVideoChanged(_ audio: CallMediaKind<VideoStreamable>) {
        switch audio {
        case .twoWay:
            // TODO
            call.state.value = .started
            action?(.connected(name: interactor.engagedOperator?.firstName,
                               imageUrl: interactor.engagedOperator?.picture?.url))
            action?(.setInfoText(nil))
        default:
            break
        }
        updateButtons()
    }

    private func onDurationChanged(_ duration: Int) {
        let text = Strings.Connect.Connected.secondText.withCallDuration(duration.asDurationString)
        action?(.setCallDurationText(text))
    }
}

extension CallViewModel {
    private func updateButtons() {
        let chatEnabled = interactor.isEngaged
        let videoEnabled = call.video.value.hasLocalStream
        let muteEnabled = call.audio.value.hasLocalStream
        let speakerEnabled = call.audio.value.hasRemoteStream
        let minimizeEnabled = true
        action?(.setButtonEnabled(.chat, enabled: chatEnabled))
        action?(.setButtonEnabled(.video, enabled: videoEnabled))
        action?(.setButtonEnabled(.mute, enabled: muteEnabled))
        action?(.setButtonEnabled(.speaker, enabled: speakerEnabled))
        action?(.setButtonEnabled(.minimize, enabled: minimizeEnabled))

        let videoState: ButtonState = call.video.value.localStream?.isPaused == true
            ? .active
            : .inactive
        let muteState: ButtonState = call.audio.value.localStream?.isMuted == true
            ? .active
            : .inactive
        let speakerState: ButtonState = audioPortOverride == .speaker
            ? .active
            : .inactive
        action?(.setButtonState(.video, state: videoState))
        action?(.setButtonState(.mute, state: muteState))
        action?(.setButtonState(.speaker, state: speakerState))
    }

    private func buttonTapped(_ button: Button) {
        switch button {
        case .chat:
            delegate?(.chat)
        case .video:
            toggleVideo()
        case .mute:
            toggleMute()
        case .speaker:
            toggleSpeaker()
        case .minimize:
            delegate?(.minimize)
        }
    }

    private func toggleVideo() {
        call.video.value.localStream.map {
            if $0.isPaused {
                $0.resume()
            } else {
                $0.pause()
            }
        }
        updateButtons()
    }

    private func toggleMute() {
        call.audio.value.localStream.map {
            if $0.isMuted {
                $0.unmute()
            } else {
                $0.mute()
            }
        }
        updateButtons()
    }

    private func toggleSpeaker() {
        let newOverride: AVAudioSession.PortOverride = {
            switch audioPortOverride {
            case .none:
                return .speaker
            case .speaker:
                return .none
            @unknown default:
                return .none
            }
        }()

        let session = AVAudioSession.sharedInstance()
        do {
            try session.overrideOutputAudioPort(newOverride)
            audioPortOverride = newOverride
        } catch {
            print(error)
        }
        updateButtons()
    }
}
