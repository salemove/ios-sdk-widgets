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
        case switchToVideoMode
        case switchToUpgradeMode
        case setCallDurationText(String)
        case setTitle(String)
        case showButtons([CallButton])
        case setButtonEnabled(CallButton, enabled: Bool)
        case setButtonState(CallButton, state: CallButtonState)
        case setButtonBadge(CallButton, itemCount: Int)
        case setRemoteVideo(StreamView?)
        case setLocalVideo(StreamView?)
    }

    enum DelegateEvent {
        case chat
        case minimize
    }

    enum StartAction {
        case startEngagement(mediaType: MediaType)
        case fromUpgrade
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let call: Call
    private let startWith: StartAction
    private let durationCounter = CallDurationCounter()
    private let screenShareHandler: ScreenShareHandler
    private let unreadMessagesCounter: UnreadMessagesCounter
    private var disposables: [Disposable] = []

    init(
        interactor: Interactor,
        screenShareHandler: ScreenShareHandler,
        unreadMessagesCounter: UnreadMessagesCounter,
        call: Call,
        startAction: StartAction
    ) {
        self.call = call
        self.screenShareHandler = screenShareHandler
        self.unreadMessagesCounter = unreadMessagesCounter
        self.startWith = startAction

        super.init(
            interactor: interactor,
            screenShareHandler: screenShareHandler
        )

        call.kind
            .observe({ [weak self] in
                self?.onKindChanged($0)
            })
            .add(to: &disposables)

        call.state
            .observe({ [weak self] in
                self?.onStateChanged($0)
            })
            .add(to: &disposables)

        call.video.stream
            .observe({ [weak self] in
                self?.onVideoChanged($0)
            })
            .add(to: &disposables)

        call.audio.stream
            .observe({ [weak self] in
                self?.onAudioChanged($0)
            })
            .add(to: &disposables)

        call.duration
            .observe({ [weak self] in
                self?.onDurationChanged($0)
            })
            .add(to: &disposables)

        unreadMessagesCounter.unreadMessagesCount
            .observe({ [weak self] in
                self?.action?(.setButtonBadge(.chat, itemCount: $0))
            })
            .add(to: &disposables)
    }

    func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()

        case .callButtonTapped(let button):
            callButtonTapped(button)
        }
    }

    override func start() {
        super.start()

        if let callKind = call.kind.value {
            update(for: callKind)
        }

        switch startWith {
        case .startEngagement(let mediaType):
            enqueue(mediaType: mediaType)

        case .fromUpgrade:
            showConnecting()
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            action?(.queue)
        case .engaged:
            if case .startEngagement = startWith {
                showConnecting()
            }

            let operatorName = Strings.Operator.name.withOperatorName(
                interactor.engagedOperator?.firstName
            )

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
        action?(
            .connecting(
                name: interactor.engagedOperator?.firstName,
                imageUrl: interactor.engagedOperator?.picture?.url
            )
        )

        if let callKind = call.kind.value {
            switch callKind {
            case .audio:
                action?(.setTopTextHidden(true))

            case .video:
                action?(.setTopTextHidden(false))
            }
        }
    }

    private func showConnected() {
        action?(.setTopTextHidden(true))
        action?(.setBottomTextHidden(true))

        if let screenShareState = screenShareHandler.status.value {
            switch screenShareState {
            case .started:
                engagementAction?(.showEndScreenShareButton)

            case .stopped:
                engagementAction?(.showEndButton)
            }
        }

        if let callKind = call.kind.value {
            switch callKind {
            case .audio:
                action?(
                    .connected(
                        name: interactor.engagedOperator?.firstName,
                        imageUrl: interactor.engagedOperator?.picture?.url
                    )
                )
            case .video:
                break
            }
        }
    }

    private func handleAudioStreamError(_ error: SalemoveError) {
        switch error.error {
        case let mediaError as MediaError:
            switch mediaError {
            case .permissionDenied:
                engagementDelegate?(
                    .alert(.microphoneSettings)
                )

            default:
                handleError(error)
            }

        default:
            handleError(error)
        }
    }

    private func handleVideoStreamError(_ error: SalemoveError) {
        switch error.error {
        case let mediaError as MediaError:
            switch mediaError {
            case .permissionDenied:
                engagementDelegate?(
                    .alert(.cameraSettings)
                )

            default:
                handleError(error)
            }

        default:
            handleError(error)
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
        if let remoteStream = call.video.stream.value?.remoteStream {
            showRemoteVideo(with: remoteStream)
        } else {
            hideRemoteVideo()
        }
    }

    private func updateLocalVideoVisible() {
        if let localStream = call.video.stream.value?.localStream,
           !localStream.isPaused {
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
            durationCounter.start { [weak self] duration in
                guard
                    self?.call.state.value == .started
                else { return }

                self?.call.updateDuration(with: duration)
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
        let text = Strings.Connect.Connected.secondText.withCallDuration(
            duration.asDurationString
        )
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
        if let callKind = call.kind.value {
            switch callKind {
            case .audio:
                return [.chat, .mute, .speaker, .minimize]

            case .video:
                return [.chat, .video, .mute, .speaker, .minimize]
            }
        } else {
            return []
        }
    }

    private func updateChatButton() {
        let enabled = interactor.isEngaged
        action?(.setButtonEnabled(.chat, enabled: enabled))
    }

    private func updateVideoButton() {
        let enabled = call.video.stream.value?.hasLocalStream ?? false
        let state: CallButtonState = call.video.stream.value?.localStream.map {
            $0.isPaused ? .inactive : .active
        } ?? .inactive

        action?(.setButtonEnabled(.video, enabled: enabled))
        action?(.setButtonState(.video, state: state))
    }

    private func updateMuteButton() {
        let enabled = call.audio.stream.value?.hasLocalStream ?? false
        let state: CallButtonState = call.audio.stream.value?.localStream?.isMuted == true
            ? .active
            : .inactive

        action?(.setButtonEnabled(.mute, enabled: enabled))
        action?(.setButtonState(.mute, state: state))
    }

    private func updateSpeakerButton() {
        let enabled = call.audio.stream.value?.hasRemoteStream ?? false
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
