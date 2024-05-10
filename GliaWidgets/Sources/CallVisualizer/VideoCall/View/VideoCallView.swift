import UIKit

extension CallVisualizer {
    final class VideoCallView: BaseView {

        // MARK: - Properties

        var props: Props {
            didSet {
                renderProps()
            }
        }

        var renderCallDuration: String? {
            didSet {
                guard renderCallDuration != oldValue else { return }
                secondLabel.text = renderCallDuration
                secondLabel.accessibilityLabel = renderCallDuration
            }
        }

        var renderOperatorName: String? = "" {
            didSet {
                guard renderOperatorName != oldValue else { return }
                operatorNameLabel.text = renderOperatorName
                operatorNameLabel.accessibilityLabel = renderOperatorName
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
        let connectView: ConnectView

        private lazy var topLabel = UILabel().make { label in
            label.text = props.style.topText
            label.font = props.style.topTextFont
            label.textColor = props.style.topTextColor
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = props.style.topTextFont
        }

        private lazy var secondLabel = UILabel().make { label in
            label.font = props.style.durationFont
            label.textColor = props.style.durationColor
            label.textAlignment = .center
        }

        private lazy var header = Header(props: props.headerProps).make { header in
            header.endButton?.isHidden = true
            header.closeButton?.isHidden = true
            header.endScreenShareButton?.isHidden = true

            if let backButton = props.style.header.backButton {
                header.backButton?.accessibilityLabel = backButton.accessibility.label
                header.backButton?.accessibilityHint = backButton.accessibility.hint
            }
        }

        private lazy var topStackView = UIStackView().make {
            $0.axis = .vertical
            $0.spacing = 8
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

        lazy var operatorNameLabel = UILabel().make {
            $0.accessibilityHint = props.style.accessibility.operatorNameHint
            $0.font = props.style.operatorNameFont
            $0.textColor = props.style.operatorNameColor
            $0.textAlignment = .center
        }

        // MARK: - Initializer

        init(props: Props, environment: Environment) {
            self.props = props
            self.buttonBar = .init(props: props.buttonBarProps)
            self.connectView = .init(props: props.connectViewProps)
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
            topStackView.addArrangedSubviews([operatorNameLabel, secondLabel])
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: operatorNameLabel
            )
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: secondLabel
            )
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
            constraints += connectView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10)
            constraints += connectView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
            constraints += connectView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
            constraints += connectView.centerXAnchor.constraint(equalTo: centerXAnchor)

            addSubview(topStackView)
            topStackView.translatesAutoresizingMaskIntoConstraints = false
            constraints += topStackView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 50)
            constraints += topStackView.centerXAnchor.constraint(equalTo: centerXAnchor)

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
        let connectViewProps: CallVisualizer.VideoCallView.ConnectView.Props
        let buttonBarProps: CallVisualizer.VideoCallView.CallButtonBar.Props
        let headerTitle: String
        let operatorName: String?
        let remoteVideoStream: CoreSdkClient.StreamView?
        let localVideoStream: CoreSdkClient.StreamView?
        let topLabelHidden: Bool
        let endScreenShareButtonHidden: Bool
        let connectViewHidden: Bool
        let topStackAlpha: CGFloat
        let headerProps: Header.Props
        let flipCameraTap: Cmd?
        let flipCameraAccLabel: String
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView {
    func renderProps() {
        renderCallDuration = props.callDuration
        connectView.props = props.connectViewProps
        buttonBar.props = props.buttonBarProps
        renderOperatorName = props.operatorName
        renderRemoteVideoStream = props.remoteVideoStream
        renderLocalVideoStream = props.localVideoStream
        topLabel.isHidden = props.topLabelHidden
        header.endScreenShareButton?.isHidden = props.endScreenShareButtonHidden
        connectView.isHidden = props.connectViewHidden
        topStackView.alpha = props.topStackAlpha
        header.props = props.headerProps
        localVideoView.flipCameraAccessibilityLabelWithTap = props.flipCameraTap.map { tap in (props.flipCameraAccLabel, tap) }
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

extension CallVisualizer.VideoCallView {
    struct Environment {
        let gcd: GCD
        let uiScreen: UIKitBased.UIScreen
    }
}
