import UIKit

extension CallVisualizer {
    final class VideoCallView: BaseView {
        // MARK: - Properties

        var props: Props {
            didSet {
                renderProps()
            }
        }

        var renderLocalVideoStream: CoreSdkClient.StreamView? {
            didSet {
                guard renderLocalVideoStream != oldValue else { return }
                localVideoView.streamView = renderLocalVideoStream
            }
        }

        var renderRemoteVideoStream: CoreSdkClient.StreamView? {
            didSet {
                guard renderRemoteVideoStream != oldValue else { return }
                remoteVideoView.streamView = renderRemoteVideoStream
            }
        }

        private let environment: Environment
        private var hideBarsWorkItem: DispatchWorkItem?
        private var headerTopConstraint: NSLayoutConstraint!
        private var buttonBarBottomConstraint: NSLayoutConstraint!
        private var remoteVideoViewHeightConstraint: NSLayoutConstraint!
        private var remoteVideoViewWidthConstraint: NSLayoutConstraint!
        private let barsHideDelay: TimeInterval = 3.2
        private let effectView: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .dark)
            let effectView = UIVisualEffectView(effect: effect)
            return effectView
        }()
        let buttonBar: CallButtonBar
        let connectView: CallConnectViewHost

        private lazy var topLabel = UILabel().make { label in
            label.text = props.style.topText
            label.font = props.style.topTextFont
            label.textColor = props.style.topTextColor
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = props.style.topTextFont
        }

        lazy var header = Header(props: props.headerProps).make { header in
            header.hideCloseAndEndButtons()

            if let backButton = props.style.header.backButton {
                header.backButton?.accessibilityLabel = backButton.accessibility.label
                header.backButton?.accessibilityHint = backButton.accessibility.hint
            }
        }

        private var localVideoBounds: CGRect {
            let x = safeAreaInsets.left + 10
            let y = header.frame.maxY + 10
            let width = frame.width - safeAreaInsets.left - safeAreaInsets.right - 2 * 10
            let height = buttonBar.frame.minY - header.frame.maxY - 2 * 10

            return CGRect(x: x, y: y, width: width, height: height)
        }

        lazy var localVideoView: VideoStreamView = {
            let streamView = VideoStreamView(
                .local,
                flipCameraButtonStyle: props.style.flipCameraButtonStyle
            )
            streamView.accessibilityLabel = props.style.accessibility.localVideoLabel
            streamView.accessibilityIdentifier = "call_visualizer_visitor_video_view"
            return streamView
        }()

        lazy var remoteVideoView: VideoStreamView = {
            let streamView = VideoStreamView(
                .remote,
                flipCameraButtonStyle: props.style.flipCameraButtonStyle
            )
            streamView.accessibilityLabel = props.style.accessibility.remoteVideoLabel
            streamView.accessibilityIdentifier = "call_visualizer_operator_video_view"
            return streamView
        }()

        // MARK: - Initializer

        init(props: Props, environment: Environment) {
            self.props = props
            self.buttonBar = .init(props: props.buttonBarProps)
            self.connectView = CallConnectViewHost(
                connectStyle: props.style.connect,
                callStyle: props.style,
                durationHint: props.style.connect.connected.accessibility.secondTextHint,
                imageCache: environment.imageViewCache
            )
            self.environment = environment
            super.init()
            layout()
        }

        @available(*, unavailable)
        required init() {
            fatalError("init() has not been implemented")
        }

        // MARK: - Overrides

        override func setup() {
            accessibilityIdentifier = "Call_Visualizer_Video_View"
            connectView.setMode(.video)
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: topLabel
            )

            let tapRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(tap)
            )
            addGestureRecognizer(tapRecognizer)

            localVideoView.show = { [weak self] in
                self?.setLocalVideoFrame(isVisible: $0)
            }

            localVideoView.pan = { [weak self] in
                self?.adjustLocalVideoFrameAfterPanGesture(translation: $0)
            }
        }

        func layout() {
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            addSubview(effectView)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            constraints += effectView.layoutInSuperview()

            addSubview(remoteVideoView)
            remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
            constraints += remoteVideoView.centerYAnchor.constraint(equalTo: centerYAnchor)
            constraints += remoteVideoView.centerXAnchor.constraint(equalTo: centerXAnchor)
            let (widthConstraing, heightConstraint) = (
                remoteVideoView.match(.height, value: 0), remoteVideoView.match(.width, value: 0)
            )
            remoteVideoViewWidthConstraint = widthConstraing.first
            remoteVideoViewHeightConstraint = heightConstraint.first
            constraints += widthConstraing
            constraints += heightConstraint

            addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            headerTopConstraint = header.topAnchor.constraint(equalTo: topAnchor)
            constraints += headerTopConstraint
            constraints += header.layoutInSuperview(edges: .horizontal)

            addSubview(topLabel)
            topLabel.translatesAutoresizingMaskIntoConstraints = false
            constraints += topLabel.topAnchor.constraint(equalTo: header.bottomAnchor)
            constraints += topLabel.layoutIn(safeAreaLayoutGuide, edges: .horizontal, insets: .init(top: 0, left: 20, bottom: 0, right: 20))

            addSubview(connectView)
            connectView.translatesAutoresizingMaskIntoConstraints = false
            constraints += connectView.topAnchor.constraint(equalTo: header.bottomAnchor)
            constraints += connectView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            constraints += connectView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
            constraints += connectView.heightAnchor.constraint(greaterThanOrEqualToConstant: 265)

            addSubview(buttonBar)
            buttonBar.translatesAutoresizingMaskIntoConstraints = false
            buttonBarBottomConstraint = buttonBar.bottomAnchor.constraint(equalTo: bottomAnchor)
            constraints += buttonBarBottomConstraint
            constraints += buttonBar.layoutInSuperview(edges: .horizontal)

            addSubview(localVideoView)

            adjustVideoViews()
            adjustLocalVideoFrameAfterLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            adjustVideoViews()
            adjustLocalVideoFrameAfterLayout()

            switch props.style.backgroundColor {
            case .fill(color: let color):
                backgroundColor = color
            case .gradient(colors: let colors):
                makeGradientBackground(colors: colors)
            }
        }

        // MARK: - Methods

        func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
            if orientation.isLandscape {
                hideLandscapeBarsAfterDelay()
            } else {
                showBars(duration: duration)
            }
        }

        func didRotate() {
            adjustLocalVideoFrameAfterOrientationChange()
        }

        func checkBarsOrientation() {
            if currentOrientation.isLandscape {
                hideLandscapeBarsAfterDelay()
            } else {
                headerTopConstraint.constant = 0
                buttonBarBottomConstraint.constant = 0
            }
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallView {
    struct Props: Equatable {
        let style: CallStyle
        let callDuration: String?
        let connectState: EngagementState
        let buttonBarProps: CallVisualizer.VideoCallView.CallButtonBar.Props
        let remoteVideoStream: CoreSdkClient.StreamView?
        let localVideoStream: CoreSdkClient.StreamView?
        let topLabelHidden: Bool
        let headerProps: Header.Props
        let flipCameraTap: Cmd?
        let flipCameraPropsAccessibility: FlipCameraButton.Props.Accessibility
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView {
    func renderProps() {
        connectView.setState(props.connectState, durationText: props.callDuration)
        buttonBar.props = props.buttonBarProps
        renderRemoteVideoStream = props.remoteVideoStream
        renderLocalVideoStream = props.localVideoStream
        topLabel.isHidden = props.topLabelHidden
        header.props = props.headerProps
        localVideoView.flipCameraAccessibilityLabelWithTap = props.flipCameraTap
            .map { tap in (props.flipCameraPropsAccessibility, tap) }
    }

    func adjustVideoViews() {
        adjustRemoteVideoView()
    }

    func adjustRemoteVideoView() {
        remoteVideoViewHeightConstraint.constant = frame.size.height
        remoteVideoViewWidthConstraint.constant = frame.size.width
    }

    func showBars(duration: TimeInterval) {
        layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            self.headerTopConstraint.constant = 0
            self.buttonBarBottomConstraint.constant = 0
            self.layoutIfNeeded()
        }
    }

    func hideBars(duration: TimeInterval) {
        layoutIfNeeded()
        let newHeaderConstraint = -header.frame.size.height + safeAreaInsets.top
        UIView.animate(withDuration: duration) {
            self.headerTopConstraint.constant = newHeaderConstraint
            self.buttonBarBottomConstraint.constant = self.buttonBar.frame.size.height
            self.layoutIfNeeded()
        }
    }

    func hideLandscapeBars() {
        guard currentOrientation.isLandscape else { return }
        hideBars(duration: 0.3)
    }

    func hideLandscapeBarsAfterDelay() {
        hideBarsWorkItem?.cancel()
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + barsHideDelay) {
            self.hideLandscapeBars()
        }
    }

    @objc func tap() {
        if currentOrientation.isLandscape {
            showBars(duration: 0.3)
            hideLandscapeBarsAfterDelay()
        } else {
            showBars(duration: 0.3)
        }
    }

    func setLocalVideoFrame(isVisible: Bool) {
        if isVisible {
            let screenSize: CGRect = environment.uiScreen.bounds()

            let size = CGSize(
                width: screenSize.width * 0.3,
                height: screenSize.height * 0.3
            )

            localVideoView.frame = CGRect(
                origin: CGPoint(
                    x: localVideoBounds.maxX - size.width,
                    y: localVideoBounds.maxY - size.height
                ),
                size: size
            )
        }
    }

    func adjustLocalVideoFrameAfterOrientationChange() {
        let screenSize: CGRect = environment.uiScreen.bounds()

        let size = CGSize(
            width: screenSize.width * 0.3,
            height: screenSize.height * 0.3
        )

        localVideoView.frame = CGRect(
            origin: CGPoint(
                x: localVideoBounds.maxX - size.width,
                y: localVideoBounds.maxY - size.height
            ),
            size: size
        )
    }

    func adjustLocalVideoFrameAfterPanGesture(translation: CGPoint) {
        var frame = localVideoView.frame

        frame.origin.x += translation.x
        frame.origin.y += translation.y

        localVideoView.frame = frame

        if localVideoBounds.contains(frame) {
            localVideoView.frame = frame
        }
    }

    func adjustLocalVideoFrameAfterLayout() {
        var frame: CGRect = localVideoView.frame

        if localVideoView.frame.minX < localVideoBounds.minX {
            frame.origin.x = localVideoBounds.minX
        }

        if localVideoView.frame.minY < localVideoBounds.minY {
            frame.origin.y = localVideoBounds.minY
        }

        if localVideoView.frame.maxX > localVideoBounds.maxX {
            frame.origin.x = localVideoBounds.maxX - localVideoView.frame.width
        }

        if localVideoView.frame.maxY > localVideoBounds.maxY {
            frame.origin.y = localVideoBounds.maxY - localVideoView.frame.height
        }

        localVideoView.frame = frame
    }
}
