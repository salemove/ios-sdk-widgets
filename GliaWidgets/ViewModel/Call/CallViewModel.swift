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
        call.kind.addObserver(self) { kind, _ in
            self.onKindChanged(kind)
        }
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
        update(for: call.kind.value)

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
        case .video:
            action?(.setTitle(Strings.Video.title))
        }
        updateButtons()
    }

    private func requestMedia() {
        let name = interactor.engagedOperator?.firstName
        let imageUrl = interactor.engagedOperator?.picture?.url
        action?(.connecting(name: name, imageUrl: imageUrl))

        let mediaType: MediaType = {
            switch call.kind.value {
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

    private func handleAudioStreamError(_ error: SalemoveError) {
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

    private func handleVideoStreamError(_ error: SalemoveError) {
        switch error.error {
        case let mediaError as MediaError:
            switch mediaError {
            case .permissionDenied:
                self.showSettingsAlert(with: alertConfiguration.cameraSettings)
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
        let onAccepted = { [weak self] in
            answer(true, nil)
            self?.call.kind.value = .video
            // show Connecting
        }
        action?(.offerMediaUpgrade(configuration.withOperatorName(operatorName),
                                   accepted: { onAccepted() },
                                   declined: { answer(false, nil) }))
    }

    private func checkCallStart() {
        switch call.kind.value {
        case .audio:
            switch call.audio.value {
            case .twoWay:
                call.state.value = .started
            default:
                break
            }
        case .video:
            switch call.video.value {
            case .remote:
                call.state.value = .started
            default:
                break
            }
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .audioStreamAdded(let stream):
            updateMediaKind(call.audio, with: stream, isRemote: stream.isRemote)
        case .videoStreamAdded(let stream):
            updateMediaKind(call.video, with: stream, isRemote: stream.isRemote)
        case .audioStreamError(let error):
            handleAudioStreamError(error)
        case .videoStreamError(let error):
            handleVideoStreamError(error)
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
            // TODO audio vs video call
            action?(.connected(name: interactor.engagedOperator?.firstName,
                               imageUrl: interactor.engagedOperator?.picture?.url))
            action?(.setInfoText(nil))
        case .ended:
            durationCounter.stop()
        }
        updateButtons()
    }

    private func onKindChanged(_ kind: CallKind) {
        update(for: kind)
    }

    private func onAudioChanged(_ audio: CallMediaKind<AudioStreamable>) {
        checkCallStart()
        updateButtons()
    }

    private func onVideoChanged(_ video: CallMediaKind<VideoStreamable>) {
        checkCallStart()
        updateButtons()
    }

    private func onDurationChanged(_ duration: Int) {
        let text = Strings.Connect.Connected.secondText.withCallDuration(duration.asDurationString)
        action?(.setCallDurationText(text))
    }
}

extension CallViewModel {
    private func updateButtons() {
        updateVisibleButtons()
        updateChatButton()
        updateVideoButton()
        updateMuteButton()
        updateSpeakerButton()
        updateMinimizeButton()
    }

    private func updateVisibleButtons() {
        let buttons = self.buttons(for: call)
        action?(.showButtons(buttons))
    }

    private func buttons(for call: Call) -> [Button] {
        switch call.kind.value {
        case .audio:
            return [.chat, .mute, .speaker, .minimize]
        case .video:
            return [.chat, .video, .mute, .speaker, .minimize]
        }
    }

    private func updateChatButton() {
        let enabled = interactor.isEngaged
        action?(.setButtonEnabled(.chat, enabled: enabled))
    }

    private func updateVideoButton() {
        let enabled = call.video.value.hasLocalStream
        let state: ButtonState = call.video.value.localStream.map {
            $0.isPaused ? .inactive : .active
        } ?? .inactive
        action?(.setButtonEnabled(.video, enabled: enabled))
        action?(.setButtonState(.video, state: state))
    }

    private func updateMuteButton() {
        let enabled = call.audio.value.hasLocalStream
        let state: ButtonState = call.audio.value.localStream?.isMuted == true
            ? .active
            : .inactive
        action?(.setButtonEnabled(.mute, enabled: enabled))
        action?(.setButtonState(.mute, state: state))
    }

    private func updateSpeakerButton() {
        let enabled = call.audio.value.hasRemoteStream
        let state: ButtonState = audioPortOverride == .speaker
            ? .active
            : .inactive
        action?(.setButtonEnabled(.speaker, enabled: enabled))
        action?(.setButtonState(.speaker, state: state))
    }

    private func updateMinimizeButton() {
        let enabled = true
        action?(.setButtonEnabled(.minimize, enabled: enabled))
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
        updateVideoButton()
    }

    private func toggleMute() {
        call.audio.value.localStream.map {
            if $0.isMuted {
                $0.unmute()
            } else {
                $0.mute()
            }
        }
        updateMuteButton()
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
        updateSpeakerButton()
    }
}
