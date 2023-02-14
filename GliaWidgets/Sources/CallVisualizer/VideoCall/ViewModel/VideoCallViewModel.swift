import UIKit

extension CallVisualizer {
    final class VideoCallViewModel {

        // MARK: - Properties

        private let delegate: Command<DelegateEvent>
        private let environment: Environment
        private let style: CallStyle
        private var state: State = .initial
        private let durationCounter: CallDurationCounter
        private var imageDownloadID: String = ""
        private let call: Call
        private var connectTimer: FoundationBased.Timer?
        private var connectCounter: Int = 0

        // MARK: - Operator properties

        private var connectOperatorSize: SizeObject = .init(size: .normal, animated: true) {
            didSet {
                reportChange()
            }
        }

        private var operatorImageVisible: Bool = false {
            didSet {
                reportChange()
            }
        }

        private var operatorName: String? = "" {
            didSet {
                reportChange()
            }
        }

        private var operatorImagePlaceholder: UIImage? {
            didSet {
                reportChange()
            }
        }

        private var animateOperator: Bool = false {
            didSet {
                reportChange()
            }
        }

        private var operatorImage: OperatorImage? {
            didSet {
                reportChange()
            }
        }

        private var connectViewHidden: Bool = true {
            didSet {
                reportChange()
            }
        }

        private var connectVisibility: Transaition = .show(animation: true) {
            didSet {
                reportChange()
            }
        }

        // MARK: - Status Properties

        private var statusStyle: ConnectStatusStyle {
            didSet {
                reportChange()
            }
        }

        private var statusFirstText: AnimatedText = "" {
            didSet {
                reportChange()
            }
        }

        private var statusSecondText: AnimatedText = "" {
            didSet {
                reportChange()
            }
        }

        // MARK: - ButtonBar Properties

        private var videoButtonState: CallButton.State = .active {
            didSet {
                reportChange()
            }
        }

        private var minimizeButtonState: CallButton.State = .inactive {
            didSet {
                reportChange()
            }
        }

        private var videoButtonEnabled: Bool = true {
            didSet {
                reportChange()
            }
        }

        private var minimizeButtonEnabled: Bool = true {
            didSet {
                reportChange()
            }
        }

        // MARK: - Other Properties

        private var title: String = L10n.Call.Video.title {
            didSet {
                reportChange()
            }
        }

        private var callDuration: String = "" {
            didSet {
                reportChange()
            }
        }

        private var remoteVideoStream: CoreSdkClient.StreamView? {
            didSet {
                reportChange()
            }
        }

        private var localVideoStream: CoreSdkClient.StreamView? {
            didSet {
                reportChange()
            }
        }

        private var topLabelHidden: Bool = false {
            didSet {
                reportChange()
            }
        }

        private var bottomLabelHidden: Bool = false {
            didSet {
                reportChange()
            }
        }

        private var endScreenShareButtonHidden: Bool = true {
            didSet {
                reportChange()
            }
        }

        // MARK: - Initializer
//
        init(
            style: CallStyle,
            environment: Environment,
            delegate: Command<DelegateEvent>,
            call: Call
        ) {
            self.style = style
            self.delegate = delegate
            self.environment = environment
            self.call = call
            self.durationCounter = CallDurationCounter(
                environment: .init(
                    timerProviding: environment.timerProviding,
                    date: environment.date
                )
            )
            statusStyle = style.connect.connecting

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
            self.environment.screenShareHandler.status.addObserver(self) { [weak self] status, _ in
                self?.onScreenSharingStatusChange(status)
            }
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallViewModel {
    typealias Props = CallVisualizer.VideoCallViewController.Props
    typealias SizeObject = CallVisualizer.VideoCallView.ConnectOperatorView.Props.SizeObject
    typealias OperatorImage = CallVisualizer.VideoCallView.OperatorImageView.Props

    func makeProps() -> Props {
        let connectViewProps = makeConnectViewProps()
        let buttonBarProps = makeButtonBarProps()

        return Props(
            videoCallViewProps: .init(
                style: style,
                backButtonTap: .init { [weak self] in
                    self?.delegate(.minimized)
                },
                endScreenShareTap: .init { [weak self] in
                    self?.environment.screenShareHandler.stop()
                },
                callDuration: callDuration,
                connectViewProps: connectViewProps,
                buttonBarProps: buttonBarProps,
                headerTitle: title,
                operatorName: operatorName,
                remoteVideoStream: remoteVideoStream,
                localVideoStream: localVideoStream,
                topLabelHidden: topLabelHidden,
                bottomLabelHidden: bottomLabelHidden,
                endScreenShareButtonHidden: endScreenShareButtonHidden,
                connectViewHidden: connectViewHidden
            )
        )
    }
}

// MARK: - ConnectView Handler

extension CallVisualizer.VideoCallViewModel {
    func setConnectViewState(_ state: State, animated: Bool) {
        self.state = state
        switch state {
        case .initial:
            stopConnectTimer()
            connectVisibility = .hide(animation: animated)
        case .queue:
            stopConnectTimer()
            operatorImagePlaceholder = style.connect.connectOperator.operatorImage.placeholderImage
            animateOperator = animated
            statusFirstText = .init(text: style.connect.queue.firstText, animated: false)
            statusSecondText = .init(text: style.connect.queue.secondText, animated: false)
            statusStyle = style.connect.queue
            connectVisibility = .show(animation: animated)
        case .connecting(let name, let imageUrl):
            animateOperator = animated
            operatorImagePlaceholder = style.connect.connectOperator.operatorImage.placeholderImage
            setOperatorImage(from: imageUrl, animated: animated)
            operatorImageVisible = true
            let firstText = style.connect.connecting.firstText?.withOperatorName(name)
            statusFirstText = .init(text: firstText, animated: animated)
            statusSecondText = .init(text: nil, animated: animated)
            statusStyle = style.connect.connecting
            startConnectTimer()
            connectVisibility = .show(animation: animated)
        case .connected(let name, let imageUrl):
            stopConnectTimer()
            animateOperator = animated
            operatorImagePlaceholder = style.connect.connectOperator.operatorImage.placeholderImage
            setOperatorImage(from: imageUrl, animated: animated)
            operatorImageVisible = false
            if let name = name {
                let firstText = style.connect.connected.firstText?.withOperatorName(name)
                let secondText = style.connect.connected.secondText?
                    .withOperatorName(name)
                    .withCallDuration("00:00")
                statusFirstText = .init(text: firstText, animated: animated)
                statusSecondText = .init(text: secondText, animated: animated)
            } else {
                statusFirstText = .init(text: nil, animated: animated)
                statusSecondText = .init(text: nil, animated: animated)
            }
            statusStyle = style.connect.connected
            connectVisibility = .show(animation: animated)
        case .transferring:
            break
        }
    }
}

// MARK: - Make Props

private extension CallVisualizer.VideoCallViewModel {
    func reportChange() {
        delegate(.propsUpdated(makeProps()))
    }

    func makeOperatorImageViewProps() -> CallVisualizer.VideoCallView.OperatorImageView.Props {
        return operatorImage ?? .init()
    }

    func makeUserImageProps() -> CallVisualizer.VideoCallView.UserImageView.Props {
        let operatorImageProps = makeOperatorImageViewProps()
        return .init(
            style: style.connect.connectOperator.operatorImage,
            operatorImageViewProps: operatorImageProps,
            operatorImageVisible: operatorImageVisible,
            placeHolderImage: operatorImagePlaceholder
        )
    }

    func makeConnetOperatorViewProps() -> CallVisualizer.VideoCallView.ConnectOperatorView.Props {
        let userImageProps = makeUserImageProps()
        return .init(
            style: style.connect.connectOperator,
            size: .init(
                size: connectOperatorSize.size,
                animated: connectOperatorSize.animated
            ),
            operatorAnimate: animateOperator,
            userImageViewProps: userImageProps
        )
    }

    func makeConnectStatusViewProps() -> CallVisualizer.VideoCallView.ConnectStatusView.Props {
        return .init(
            style: statusStyle,
            firstLabelText: .init(
                text: statusFirstText.text,
                animated: statusFirstText.animated
            ),
            secondLabelText: .init(
                text: statusSecondText.text,
                animated: statusSecondText.animated
            )
        )
    }

    func makeConnectViewProps() -> CallVisualizer.VideoCallView.ConnectView.Props {
        let connectOperatorViewProps = makeConnetOperatorViewProps()
        let connectStatusViewProps = makeConnectStatusViewProps()
        let connectViewProps: CallVisualizer.VideoCallView.ConnectView.Props = .init(
            operatorViewProps: connectOperatorViewProps,
            statusViewProps: connectStatusViewProps,
            state: state,
            transition: connectVisibility
        )

        return connectViewProps
    }

    func makeButtonBarProps() -> CallVisualizer.VideoCallView.CallButtonBar.Props {
        return .init(
            style: style.buttonBar,
            videoButtonTap: .init { [weak self] in
                self?.toggleVideo()
            },
            minimizeTap: .init { [weak self] in
                self?.delegate(.minimized)
            },
            videoButtonState: videoButtonState,
            minimizeButtonState: minimizeButtonState,
            videoButtonEnabled: videoButtonEnabled,
            minimizeButtonEnabled: minimizeButtonEnabled
        )
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallViewModel {

    func update(for state: InteractorState) {
        switch state {
        case .enqueueing:
            setConnectViewState(.queue, animated: false)
        case .engaged:
            showConnecting()

            let operatorName = L10n.Call.Operator.name.withOperatorName(
                environment.engagedOperator()?.firstName
            )
            self.operatorName = operatorName
        case .ended:
            call.end()
        default:
            break
        }
    }

    func toggleVideo() {
        call.toggleVideo()
        updateVideoButton()
        updateLocalVideoVisible()
    }

    func setButtonState(kind: CallButton.Kind, state: CallButton.State) {
        switch kind {
        case .chat, .mute, .speaker:
            break
        case .video:
            videoButtonState = state
        case .minimize:
            minimizeButtonState = state
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

    func setOperatorImage(
        from url: String?,
        animated: Bool,
        imageReceived: ((UIImage?) -> Void)? = nil
    ) {
        guard
            let urlString = url,
            let url = URL(string: urlString)
        else {
            imageReceived?(nil)
            operatorImage = .init(image: nil, animated: animated)
            return
        }

        if let image = environment.imageViewCache.getImageForKey(urlString) {
            imageReceived?(image)
            operatorImage = .init(image: image, animated: animated)
            return
        }

        let downloadID = environment.uuid().uuidString
        self.imageDownloadID = downloadID
        environment.gcd.globalQueue.async { [weak self] in
            guard
                let data = try? self?.environment.data.dataWithContentsOfFileUrl(url),
                let image = UIImage(data: data)
            else {
                self?.environment.gcd.mainQueue.async {
                    imageReceived?(nil)
                    self?.operatorImage = .init(image: nil, animated: animated)
                }
                return
            }

            self?.environment.gcd.mainQueue.async {
                self?.environment.imageViewCache.setImageForKey(image, urlString)

                guard self?.imageDownloadID == downloadID else { return }
                imageReceived?(image)
                self?.operatorImage = .init(image: image, animated: animated)
            }
        }
    }

    func startConnectTimer() {
        stopConnectTimer()
        connectCounter = 0
        connectTimer = environment.timerProviding.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            switch self.state {
            case .connecting:
                self.connectCounter += 1
                self.statusSecondText = .init(text: "\(self.connectCounter)", animated: true)
            default:
                self.connectTimer?.invalidate()
                self.connectTimer = nil
            }
        }
    }

    func stopConnectTimer() {
        connectTimer?.invalidate()
        connectTimer = nil
    }

    func updateRemoteVideoVisible() {
        if let remoteStream = call.video.stream.value.remoteStream {
            connectViewHidden = true
            remoteVideoStream = remoteStream.getStreamView()
            remoteStream.playVideo()
        } else {
            remoteVideoStream = nil
        }
    }

    func updateLocalVideoVisible() {
        if let localStream = call.video.stream.value.localStream, !localStream.isPaused {
            connectViewHidden = true
            localVideoStream = localStream.getStreamView()
            localStream.playVideo()
        } else {
            localVideoStream = nil
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
        switch environment.screenShareHandler.status.value {
        case .started:
            endScreenShareButtonHidden = false
        case .stopped:
            break
        }
        let engagedOperator = environment.engagedOperator()
        setConnectViewState(.connected(name: engagedOperator?.firstName, imageUrl: engagedOperator?.picture?.url), animated: true)
        connectOperatorSize = .init(size: .large, animated: true)
        topLabelHidden = true
        bottomLabelHidden = true
        switch call.kind.value {
        case .video(let direction):
            switch direction {
            case .twoWay:
                call.video.stream.value.localStream.map {
                    localVideoStream = $0.getStreamView()
                }

            default:
                break
            }

        case .audio:
            break
        }
    }

    func showConnecting() {
        let engagedOperator = environment.engagedOperator()
        setConnectViewState(.connecting(name: engagedOperator?.firstName, imageUrl: engagedOperator?.picture?.url), animated: true)
        connectOperatorSize = .init(size: .normal, animated: true)

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
        let text = L10n.Call.Connect.Connected.secondText.withCallDuration(
            duration.asDurationString
        )
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
            title = L10n.Call.Video.title
        }
        updateButtons()
    }

    func onStateChanged(_ state: CallState) {
        switch state {
        case .none:
            break
        case .started:
            showConnected()
            durationCounter.start { [weak self] duration in
                guard self?.call.state.value == .started else { return }
                self?.call.duration.value = duration
            }
        case .connecting:
            let engagedOperator = environment.engagedOperator()
            setConnectViewState(.connecting(name: engagedOperator?.firstName, imageUrl: engagedOperator?.picture?.url), animated: true)
            connectOperatorSize = .init(size: .normal, animated: true)
        case .ended:
            durationCounter.stop()
        }

        updateButtons()
    }

    func onVideoChanged(_ stream: MediaStream<CoreSdkClient.VideoStreamable>) {
        updateButtons()
        updateRemoteVideoVisible()
        updateLocalVideoVisible()
    }

    func onScreenSharingStatusChange(_ status: ScreenSharingStatus) {
        switch status {
        case .started:
            endScreenShareButtonHidden = false
        case .stopped:
            endScreenShareButtonHidden = true
        }
    }
}

extension CallVisualizer.VideoCallViewModel {
    enum State: Equatable {
        case initial
        case queue
        case connecting(name: String?, imageUrl: String?)
        case connected(name: String?, imageUrl: String?)
        case transferring
    }

    struct AnimatedText: Equatable {
        let text: String?
        let animated: Bool
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
