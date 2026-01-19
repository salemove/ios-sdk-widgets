import UIKit

extension CallVisualizer {
    final class VideoCallViewModel {
        // MARK: - Properties

        var delegate: ((DelegateEvent) -> Void)?
        let environment: Environment
        private let style: CallStyle
        private var imageDownloadID: String = ""
        let call: Call
        let disposeBag = CoreSdkClient.DisposableBag()

        @MainActor var hideNoConnectionSnackBar: (() -> Void)?

        // MARK: - Operator properties
        private var state: EngagementState { didSet { reportChange() } }

        private var interfaceOrientation: UIInterfaceOrientation { didSet { reportChange() } }

        private var operatorImageVisible: Bool { didSet { reportChange() } }

        // MARK: - ButtonBar Properties

        private var videoButtonState: CallButton.State { didSet { reportChange() } }

        private var videoButtonEnabled: Bool { didSet { reportChange() } }

        private var minimizeButtonEnabled: Bool { didSet { reportChange() } }

        // MARK: - Other Properties

        private var title: String { didSet { reportChange() } }

        private var callDuration: String { didSet { reportChange() } }

        private var remoteVideoStream: CoreSdkClient.StreamView? { didSet { reportChange() } }

        var localVideoStream: CoreSdkClient.StreamView? { didSet { reportChange() } }

        private var topLabelHidden: Bool { didSet { reportChange() } }

        private var flipCameraAccLabelWithTap: VideoStreamView.FlipCameraAccLabelWithTap? { didSet { reportChange() } }

        // MARK: - Initializer

        init(
            style: CallStyle,
            environment: Environment,
            call: Call
        ) {
            self.style = style
            self.environment = environment
            self.call = call

            let windows = environment.uiApplication.windows()
            interfaceOrientation = windows.first(where: {
                $0.isKeyWindow
            })?.windowScene?.interfaceOrientation ?? .portrait
            state = .initial
            operatorImageVisible = false
            videoButtonState = .active
            videoButtonEnabled = true
            minimizeButtonEnabled = true
            title = Localization.Engagement.Video.title
            callDuration = ""
            topLabelHidden = false

            self.call.kind.addObserver(self) { [weak self] kind, _ in
                self?.onKindChanged(for: kind)
            }
            self.call.state.addObserver(self) { [weak self] state, _ in
                self?.onStateChanged(state)
            }
            self.call.video.stream.addObserver(self) { [weak self] video, _ in
                self?.onVideoChanged(video)
            }
            self.call.duration.addObserver(self) { [weak self] duration, _ in
                self?.onDurationChanged(duration)
            }

            environment.notificationCenter.addObserver(
                self,
                selector: #selector(handleDeviceOrientationDidChange),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )

            subscribeOnNetworkReachabilityChanges()
            subscribeOnCallQualityChanges()
        }

        deinit {
            environment.proximityManager.stop()
        }

        func close() {
            disposeBag.disposeAll()
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallViewModel {
    typealias VideoCall = CallVisualizer.VideoCallView
    typealias Props = CallVisualizer.VideoCallViewController.Props

    func makeProps() -> Props {
        let buttonBarProps = makeButtonBarProps()
        let backButton = style.header.backButton.map {
            HeaderButton.Props(
                tap: .init { [weak self] in
                    self?.delegate?(.minimized)
                },
                style: $0
            )
        }

        return Props(
            videoCallViewProps: .init(
                style: style,
                callDuration: callDuration,
                connectState: state,
                buttonBarProps: buttonBarProps,
                remoteVideoStream: remoteVideoStream,
                localVideoStream: localVideoStream,
                topLabelHidden: topLabelHidden,
                headerProps: .init(
                    title: title,
                    effect: interfaceOrientation.isLandscape ? .blur : .none,
                    endButton: .init(),
                    backButton: backButton,
                    closeButton: .init(style: style.header.closeButton),
                    style: style.header
                ),
                flipCameraTap: flipCameraAccLabelWithTap?.tapCallback,
                flipCameraPropsAccessibility: flipCameraAccLabelWithTap?.accessibility ?? .nop
            ),
            viewDidLoad: .init { [weak self] in
                self?.environment.proximityManager.start()
            }
        )
    }

    private func makeButtonBarProps() -> VideoCall.CallButtonBar.Props {
        return .init(
            style: style.buttonBar,
            videoButtonTap: .init { [weak self] in
                self?.toggleVideo()
            },
            minimizeTap: .init { [weak self] in
                self?.delegate?(.minimized)
            },
            videoButtonState: videoButtonState,
            videoButtonEnabled: videoButtonEnabled,
            minimizeButtonEnabled: minimizeButtonEnabled,
            effect: interfaceOrientation.isLandscape ? .blur : .none
        )
    }
}

// MARK: - ConnectView Handler

extension CallVisualizer.VideoCallViewModel {
    private func setState(_ state: EngagementState, animated: Bool) {
        self.state = state
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallViewModel {
    func reportChange() {
        delegate?(.propsUpdated(makeProps()))
    }

    @objc func handleDeviceOrientationDidChange() {
        handleOrientationChange()
    }

    func handleOrientationChange() {
        let windows = environment.uiApplication.windows()
        interfaceOrientation = windows.first(where: {
            $0.isKeyWindow
        })?.windowScene?.interfaceOrientation ?? .portrait
    }

    func toggleVideo() {
        environment.openTelemetry.logger.i(.callScreenButtonClicked) { [weak self] in
            guard let self else { return }
            let button: OtelButtonNames = call.hasVisitorTurnedOffVideo ? .videoOn : .videoOff
            $0[.buttonName] = .string(button.rawValue)
        }
        call.toggleVideo()
        updateVideoButton()
        updateLocalVideoVisible()
    }

    func setButtonState(kind: CallButton.Kind, state: CallButton.State) {
        switch kind {
        case .chat, .mute, .speaker, .minimize:
            break
        case .video:
            videoButtonState = state
        }
    }

    func setButtonEnabled(kind: CallButton.Kind, enabled: Bool) {
        switch kind {
        case .chat, .mute, .speaker:
            break
        case .video:
            videoButtonEnabled = enabled
        case .minimize:
            minimizeButtonEnabled = enabled
        }
    }

    func updateRemoteVideoVisible() {
        if let remoteStream = call.video.stream.value.remoteStream {
            remoteVideoStream = remoteStream.getStreamView()
            remoteStream.playVideo()
        } else {
            remoteVideoStream = nil
        }
    }

    func updateLocalVideoVisible() {
        if let localStream = call.video.stream.value.localStream, !localStream.isPaused {
            localVideoStream = localStream.getStreamView()
            localStream.playVideo()
            CallViewModel.setFlipCameraButtonVisible(
                true,
                getCameraDeviceManager: environment.cameraDeviceManager,
                log: environment.log,
                flipCameraButtonStyle: environment.theme.call.flipCameraButtonStyle,
                openTelemetry: environment.openTelemetry
            ) { [weak self] in
                self?.flipCameraAccLabelWithTap = $0
            }
        } else {
            localVideoStream = nil
            CallViewModel.setFlipCameraButtonVisible(
                false,
                getCameraDeviceManager: environment.cameraDeviceManager,
                log: environment.log,
                flipCameraButtonStyle: environment.theme.call.flipCameraButtonStyle,
                openTelemetry: environment.openTelemetry
            ) { [weak self] in
                self?.flipCameraAccLabelWithTap = $0
            }
        }
    }

    func updateButtons() {
        updateVideoButton()
        updateMinimizeButton()
    }

    func updateVideoButton() {
        let enabled = call.video.stream.value.hasLocalStream
        let state: CallButton.State = call.video.stream.value.localStream.map {
            $0.isPaused ? .inactive : .active
        } ?? .inactive
        videoButtonEnabled = enabled
        videoButtonState = state
    }

    func updateMinimizeButton() {
        let enabled = true
        minimizeButtonEnabled = enabled
    }

    func showConnected() {
        let engagedOperator = environment.engagedOperator()
        setState(.connected(name: engagedOperator?.firstName, imageUrl: engagedOperator?.picture?.url), animated: true)
        topLabelHidden = true
    }

    func showConnecting() {
        let engagedOperator = environment.engagedOperator()
        setState(.connecting(name: engagedOperator?.firstName, imageUrl: engagedOperator?.picture?.url), animated: true)
        topLabelHidden = true
        switch call.kind.value {
        case .audio:
            break
        case .video(let direction):
            switch direction {
            case .oneWay:
                topLabelHidden = false

            default:
                topLabelHidden = true
            }
        }
    }
}

// MARK: - Observer Actions

private extension CallVisualizer.VideoCallViewModel {
    func onDurationChanged(_ duration: Int) {
        let text = duration.asDurationString
        callDuration = text
    }

    func onKindChanged(for callKind: CallKind) {
        switch callKind {
        case .audio:
            break
        case .video(let direction):
            switch direction {
            case .oneWay:
                topLabelHidden = false

            default:
                topLabelHidden = true
            }
            title = Localization.Engagement.Video.title
        }
        updateButtons()
    }

    func onStateChanged(_ state: CallState) {
        switch state {
        case .none:
            break
        case .started:
            environment.log.prefixed(Self.self).info("Engagement started")
            showConnected()
        case .connecting:
            let engagedOperator = environment.engagedOperator()
            setState(.connecting(name: engagedOperator?.firstName, imageUrl: engagedOperator?.picture?.url), animated: true)
        case .ended:
            environment.log.prefixed(Self.self).info("Engagement ended")
        }
        updateButtons()
    }

    func onVideoChanged(_ stream: MediaStream<CoreSdkClient.VideoStreamable>) {
        updateButtons()
        updateRemoteVideoVisible()
        updateLocalVideoVisible()
    }
}

extension CallVisualizer.VideoCallViewModel {
    struct AnimatedText: Equatable {
        let text: String?
        let animated: Bool
    }

    struct AnimatedImage: Equatable {
        let image: UIImage?
        let animated: Bool

        init(
            image: UIImage? = UIImage(),
            animated: Bool = false
        ) {
            self.image = image
            self.animated = animated
        }
    }

    enum Transaition: Equatable {
        case show(animation: Bool)
        case hide(animation: Bool)
    }
}

extension CallVisualizer.VideoCallViewModel.AnimatedText: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        text = value
        animated = false
    }
}
