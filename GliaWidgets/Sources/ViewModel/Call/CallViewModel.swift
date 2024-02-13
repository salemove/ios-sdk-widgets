import Foundation
import UIKit

class CallViewModel: EngagementViewModel, ViewModel {
    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let call: Call
    private let startWith: StartAction
    private let durationCounter: CallDurationCounter
    private let unreadMessages: ObservableValue<Int>

    /// Speaker button state used for logging.
    private (set) var loggedSpeakerButtonOnState: Bool = false {
        didSet {
            guard loggedSpeakerButtonOnState != oldValue else { return }
            environment.log.prefixed(Self.self).info(
                "Speaker value changed to \(loggedSpeakerButtonOnState)",
                function: "\(\CallViewModel.loggedSpeakerButtonOnState)"
            )
        }
    }

    init(
        interactor: Interactor,
        alertConfiguration: AlertConfiguration,
        screenShareHandler: ScreenShareHandler,
        environment: EngagementViewModel.Environment,
        call: Call,
        unreadMessages: ObservableValue<Int>,
        startWith: StartAction
    ) {
        self.call = call
        self.startWith = startWith
        self.durationCounter = CallDurationCounter(
            environment: .init(
                timerProviding: environment.timerProviding,
                date: environment.date
            )
        )
        self.unreadMessages = unreadMessages
        super.init(
            interactor: interactor,
            alertConfiguration: alertConfiguration,
            screenShareHandler: screenShareHandler,
            environment: environment
        )
        unreadMessages.addObserver(self) { [weak self] unreadCount, _ in
            self?.action?(.setButtonBadge(.chat, itemCount: unreadCount))
        }
        self.call.kind.addObserver(self) { [weak self] kind, _ in
            self?.onKindChanged(kind)
        }
        self.call.state.addObserver(self) { [weak self] state, _ in
            self?.onStateChanged(state)
        }
        self.call.video.stream.addObserver(self) { [weak self] video, _ in
            self?.onVideoChanged(video)
        }
        self.call.audio.stream.addObserver(self) { [weak self] audio, _ in
            self?.onAudioChanged(audio)
        }
        self.call.duration.addObserver(self) { [weak self] duration, _ in
            self?.onDurationChanged(duration)
        }
        self.call.isVisitorOnHold.addObserver(self) { [weak self] isOnHold, oldValue in
            guard isOnHold != oldValue else { return }

            self?.setVisitorOnHold(isOnHold)
        }
    }

    deinit {
        environment.proximityManager.stop()
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

        environment.proximityManager.start()
        update(for: call.kind.value)

        // In the case when SDK is configured once and then
        // visitor has several Audio/Video engagements in a raw,
        // after ending each of them, `interactor.state` has `.ended` value,
        // which causes calling `call.end()` on the start of the next
        // Audio/Video engagement. That `call.end()` breaks the flow and SDK does not
        // handle `connected` state properly. So we need to skip handling `.ended` state
        // on the start of a new engagement.
        switch interactor.state {
        case .ended:
            break
        default:
            update(for: interactor.state)
        }

        switch startWith {
        case .engagement:
            break
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
            showConnecting()
            let operatorName = interactor.engagedOperator?.firstName ?? Localization.Engagement.defaultOperator
            action?(.setOperatorName(operatorName))
            showSnackBarIfNeeded()
        case .ended:
            call.end()
        default:
            break
        }
    }

    private func setVisitorOnHold(_ isOnHold: Bool) {
        if isOnHold {
            call.video.stream.value.localStream?.pause()
            action?(.setButtonState(.mute, state: .active))
        } else {
            if !call.hasVisitorMutedAudio {
                call.audio.stream.value.localStream?.unmute()
                action?(.setButtonState(.mute, state: .inactive))
            } else {
                action?(.setButtonState(.mute, state: .active))
            }

            if !call.hasVisitorTurnedOffVideo {
                call.video.stream.value.localStream?.resume()
                action?(.setButtonState(.video, state: .active))
            } else {
                action?(.setButtonState(.video, state: .inactive))
            }
        }

        action?(.setButtonEnabled(.mute, enabled: !isOnHold))
        action?(.setButtonEnabled(.video, enabled: !isOnHold))
        action?(.setVisitorOnHold(isOnHold: isOnHold))

        delegate?(.visitorOnHoldUpdated(isOnHold: isOnHold))
    }

    private func update(for callKind: CallKind) {
        switch callKind {
        case .audio:
            action?(.setTitle(Localization.Engagement.Audio.title))
            action?(.setTopTextHidden(true))
        case .video(let direction):
            switch direction {
            case .oneWay:
                action?(.setTopTextHidden(false))

            default:
                action?(.setTopTextHidden(true))
            }

            action?(.setTitle(Localization.Engagement.Video.title))
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

        switch call.kind.value {
        case .audio:
            action?(.setTopTextHidden(true))

        case .video(let direction):
            switch direction {
            case .oneWay:
                action?(.setTopTextHidden(false))

            default:
                action?(.setTopTextHidden(true))
            }
        }
    }

    private func showConnected() {
        switch screenShareHandler.status().value {
        case .started:
            engagementAction?(.showEndScreenShareButton)
        case .stopped:
            engagementAction?(.showEndButton)
        }

        action?(
            .connected(
                name: interactor.engagedOperator?.firstName,
                imageUrl: interactor.engagedOperator?.picture?.url
            )
        )

        action?(.setTopTextHidden(true))
        action?(.setBottomTextHidden(true))

        switch call.kind.value {
        case .video(let direction):
            switch direction {
            case .twoWay:
                call.video.stream.value.localStream.map {
                    showLocalVideo(with: $0)
                }

            default:
                break
            }

        case .audio:
            break
        }
    }

    func showSnackBarIfNeeded() {
        environment.fetchSiteConfigurations { [weak self] result in
            switch result {
            case let .success(site):
                guard site.mobileObservationEnabled == true else { return }
                guard site.mobileObservationIndicationEnabled == true else { return }
                self?.action?(.showSnackBarView)
            default: return
            }
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
            handleStreamError(error, with: alertConfiguration.microphoneSettings)
        case .videoStreamError(let error):
            handleStreamError(error, with: alertConfiguration.cameraSettings)
        case .upgradeOffer(let offer, answer: let answer):
            offerMediaUpgrade(offer, answer: answer)
        case .updateOffer(let offer):
            call.upgrade(to: offer)
        case .engagementTransferring:
            onEngagementTransferring()
        default:
            break
        }
    }
}

extension CallViewModel {
    private func handleStreamError(
        _ error: CoreSdkClient.SalemoveError,
        with message: SettingsAlertConfiguration
    ) {
        switch error.error {
        case let mediaError as CoreSdkClient.MediaError where mediaError == .permissionDenied:
            showSettingsAlert(
                with: message
            )
        default:
            showAlert(
                for: error
            )
        }
    }

    private func onEngagementTransferring() {
        environment.log.prefixed(Self.self).info("Transfer the call")
        endScreenSharing()
        call.transfer()
        durationCounter.stop()
        action?(.transferring)
    }
}

extension CallViewModel {
    private func offerMediaUpgrade(
        _ offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        environment.operatorRequestHandlerService.offerMediaUpgrade(
            from: interactor.engagedOperator?.firstName ?? "",
            offer: offer,
            accepted: { [weak self] in
                self?.call.upgrade(to: offer)
            },
            answer: answer
        )
    }
}

extension CallViewModel {
    private func showRemoteVideo(with stream: CoreSdkClient.VideoStreamable) {
        action?(.switchToVideoMode)
        action?(.setRemoteVideo(stream.getStreamView()))
        stream.playVideo()
    }

    private func showLocalVideo(with stream: CoreSdkClient.VideoStreamable) {
        action?(.switchToVideoMode)
        action?(.setLocalVideo(stream.getStreamView()))
        stream.onHold = { isOnHold in
            // onHold case is not handled deliberately because it
            // is handled elsewhere. This logic may need some adjustments
            // in future
            if !isOnHold {
                stream.playVideo()
            }
        }
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
        if let localStream = call.video.stream.value.localStream,
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
            environment.log.prefixed(Self.self).info("Audio or video call started")
            showConnected()
            durationCounter.start { [weak self] duration in
                guard self?.call.state.value == .started else { return }
                self?.call.duration.value = duration
            }
        case .connecting:
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

    private func onAudioChanged(_ stream: MediaStream<CoreSdkClient.AudioStreamable>) {
        updateButtons()
    }

    private func onVideoChanged(_ stream: MediaStream<CoreSdkClient.VideoStreamable>) {
        updateButtons()
        updateRemoteVideoVisible()
        updateLocalVideoVisible()
    }

    private func onDurationChanged(_ duration: Int) {
        let text = duration.asDurationString
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
        let unreadMessagesCount = unreadMessages.value

        action?(.setButtonBadge(.chat, itemCount: unreadMessagesCount))
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
        self.loggedSpeakerButtonOnState = enabled
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

extension CallViewModel {
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
        case transferring
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
        case setRemoteVideo(CoreSdkClient.StreamView?)
        case setLocalVideo(CoreSdkClient.StreamView?)
        case setVisitorOnHold(isOnHold: Bool)
        case showSnackBarView
    }

    enum DelegateEvent {
        case chat
        case minimize
        case visitorOnHoldUpdated(isOnHold: Bool)
    }

    enum StartAction {
        case engagement(mediaType: CoreSdkClient.MediaType)
        case call(offer: CoreSdkClient.MediaUpgradeOffer,
                  answer: CoreSdkClient.AnswerWithSuccessBlock)
    }
}
