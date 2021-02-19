import SalemoveSDK

class CallViewModel: EngagementViewModel, ViewModel {
    private typealias Strings = L10n.Call

    enum CallButton {
        case chat
        case video
        case mute
        case speaker
        case minimize
    }

    enum CallButtonState {
        case active
        case inactive
    }

    enum Event {
        case viewDidLoad
        case callButtonTapped(CallButton)
    }

    enum Action {
        case queue
        case connecting(name: String?, imageUrl: String?)
        case connected(name: String?, imageUrl: String?)
        case setOperatorName(String?)
        case setTopTextHidden(Bool)
        case setBottomTextHidden(Bool)
        case showEndButton
        case switchToVideoMode
        case switchToUpgradeMode
        case setCallDurationText(String)
        case setTitle(String)
        case showButtons([CallButton])
        case setButtonEnabled(CallButton, enabled: Bool)
        case setButtonState(CallButton, state: CallButtonState)
        case setButtonBadge(CallButton, itemCount: Int)
        case offerMediaUpgrade(SingleMediaUpgradeAlertConfiguration,
                               accepted: () -> Void,
                               declined: () -> Void)
        case setRemoteVideo(StreamView?)
        case setLocalVideo(StreamView?)
    }

    enum DelegateEvent {
        case chat
        case minimize
    }

    enum StartAction {
        case engagement
        case call(offer: MediaUpgradeOffer,
                  answer: AnswerWithSuccessBlock)
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let call: Call
    private let startWith: StartAction
    private let durationCounter = CallDurationCounter()

    init(interactor: Interactor,
         alertConfiguration: AlertConfiguration,
         call: Call,
         unreadMessages: ValueProvider<Int>,
         startWith: StartAction) {
        self.call = call
        self.startWith = startWith
        super.init(interactor: interactor, alertConfiguration: alertConfiguration)
        unreadMessages.addObserver(self) { unreadCount, _ in
            self.action?(.setButtonBadge(.chat, itemCount: unreadCount))
        }
        call.kind.addObserver(self) { kind, _ in
            self.onKindChanged(kind)
        }
        call.state.addObserver(self) { state, _ in
            self.onStateChanged(state)
        }
        call.video.stream.addObserver(self) { audio, _ in
            self.onVideoChanged(audio)
        }
        call.audio.stream.addObserver(self) { audio, _ in
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
        case .callButtonTapped(let button):
            callButtonTapped(button)
        }
    }

    override func start() {
        super.start()
        update(for: call.kind.value)

        switch startWith {
        case .engagement:
            enqueue()
        case .call(offer: let offer, answer: let answer):
            call.upgrade(to: offer)
            showConnecting()
            answer(true, nil)
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            action?(.queue)
        case .engaged:
            if case .engagement = startWith {
                requestMedia()
            }
            let operatorName = Strings.Operator.name.withOperatorName(interactor.engagedOperator?.firstName)
            action?(.setOperatorName(operatorName))
        case .ended:
            call.end()
        default:
            break
        }
    }

    private func update(for callKind: CallKind) {
        switch callKind {
        case .audio:
            action?(.setTitle(Strings.Audio.title))
            action?(.setTopTextHidden(true))
        case .video:
            action?(.setTitle(Strings.Video.title))
        }
        updateButtons()
    }

    private func showConnecting() {
        action?(.connecting(name: interactor.engagedOperator?.firstName,
                            imageUrl: interactor.engagedOperator?.picture?.url))

        switch call.kind.value {
        case .audio:
            action?(.setTopTextHidden(true))
        case .video:
            action?(.setTopTextHidden(false))
        }
    }

    private func showConnected() {
        action?(.showEndButton)
        action?(.setTopTextHidden(true))
        action?(.setBottomTextHidden(true))

        switch call.kind.value {
        case .audio:
            action?(.connected(name: interactor.engagedOperator?.firstName,
                               imageUrl: interactor.engagedOperator?.picture?.url))
        case .video:
            break
        }
    }

    private func requestMedia() {
        let mediaType: MediaType = {
            switch call.kind.value {
            case .audio:
                return .audio
            case .video:
                return .video
            }
        }()

        showConnecting()
        interactor.request(mediaType, direction: .twoWay) {
        } failure: { [weak self] error, salemoveError in
            if let error = error {
                self?.showAlert(for: error)
            } else if let error = salemoveError {
                self?.showAlert(for: error)
            }
        }
    }

    private func offerMediaUpgrade(_ offer: MediaUpgradeOffer, answer: @escaping AnswerWithSuccessBlock) {
        switch offer.type {
        case .video:
            let configuration = offer.direction == .oneWay
                ? alertConfiguration.oneWayVideoUpgrade
                : alertConfiguration.twoWayVideoUpgrade
            offerMediaUpgrade(with: configuration,
                              offer: offer,
                              answer: answer)
        default:
            break
        }
    }

    private func offerMediaUpgrade(with configuration: SingleMediaUpgradeAlertConfiguration,
                                   offer: MediaUpgradeOffer,
                                   answer: @escaping AnswerWithSuccessBlock) {
        guard isViewActive.value else { return }
        let operatorName = interactor.engagedOperator?.firstName
        let onAccepted = {
            self.call.upgrade(to: offer)
            answer(true, nil)
        }
        action?(.offerMediaUpgrade(configuration.withOperatorName(operatorName),
                                   accepted: { onAccepted() },
                                   declined: { answer(false, nil) }))
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

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .audioStreamAdded(let stream):
            call.updateAudioStream(with: stream)
        case .videoStreamAdded(let stream):
            call.updateVideoStream(with: stream)
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
    private func showRemoteVideo(with stream: VideoStreamable) {
        action?(.switchToVideoMode)
        action?(.setRemoteVideo(stream.getStreamView()))
        stream.playVideo()
    }

    private func showLocalVideo(with stream: VideoStreamable) {
        action?(.switchToVideoMode)
        action?(.setLocalVideo(stream.getStreamView()))
        stream.playVideo()
    }

    private func hideRemoteVideo() {
        action?(.setRemoteVideo(nil))
    }

    private func hideLocalVideo() {
        action?(.setLocalVideo(nil))
    }

    private func updateRemoteVideoVisible() {
        if let remoteStream = call.video.stream.value.remoteStream {
            showRemoteVideo(with: remoteStream)
        } else {
            hideRemoteVideo()
        }
    }

    private func updateLocalVideoVisible() {
        if let localStream = call.video.stream.value.localStream, !localStream.isPaused {
            showLocalVideo(with: localStream)
        } else {
            hideLocalVideo()
        }
    }
}

extension CallViewModel {
    private func onStateChanged(_ state: CallState) {
        switch state {
        case .none:
            break
        case .started:
            showConnected()
            durationCounter.start { duration in
                guard self.call.state.value == .started else { return }
                self.call.duration.value = duration
            }
        case .upgrading:
            action?(.switchToUpgradeMode)
            showConnecting()
        case .ended:
            durationCounter.stop()
        }
        updateButtons()
    }

    private func onKindChanged(_ kind: CallKind) {
        update(for: kind)
    }

    private func onAudioChanged(_ stream: MediaStream<AudioStreamable>) {
        updateButtons()
    }

    private func onVideoChanged(_ stream: MediaStream<VideoStreamable>) {
        updateButtons()
        updateRemoteVideoVisible()
        updateLocalVideoVisible()
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

    private func buttons(for call: Call) -> [CallButton] {
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
        let enabled = call.video.stream.value.hasLocalStream
        let state: CallButtonState = call.video.stream.value.localStream.map {
            $0.isPaused ? .inactive : .active
        } ?? .inactive
        action?(.setButtonEnabled(.video, enabled: enabled))
        action?(.setButtonState(.video, state: state))
    }

    private func updateMuteButton() {
        let enabled = call.audio.stream.value.hasLocalStream
        let state: CallButtonState = call.audio.stream.value.localStream?.isMuted == true
            ? .active
            : .inactive
        action?(.setButtonEnabled(.mute, enabled: enabled))
        action?(.setButtonState(.mute, state: state))
    }

    private func updateSpeakerButton() {
        let enabled = call.audio.stream.value.hasRemoteStream
        let state: CallButtonState = call.audioPortOverride == .speaker
            ? .active
            : .inactive
        action?(.setButtonEnabled(.speaker, enabled: enabled))
        action?(.setButtonState(.speaker, state: state))
    }

    private func updateMinimizeButton() {
        let enabled = true
        action?(.setButtonEnabled(.minimize, enabled: enabled))
    }

    private func callButtonTapped(_ button: CallButton) {
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
        call.toggleVideo()
        updateVideoButton()
        updateLocalVideoVisible()
    }

    private func toggleMute() {
        call.toggleMute()
        updateMuteButton()
    }

    private func toggleSpeaker() {
        call.toggleSpeaker()
        updateSpeakerButton()
    }
}
