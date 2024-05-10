import UIKit

extension CallView {
    struct Props {
        let header: Header.Props
    }
}

// swiftlint:disable type_body_length
class CallView: EngagementView {
    enum Mode {
        case audio
        case video
        case upgrading
    }

    var callDuration: String? {
        didSet {
            guard !isVisitrOnHold else { return }

            secondLabel.text = callDuration
            secondLabel.accessibilityLabel = callDuration

            connectView.statusView.setSecondText(callDuration, animated: false)
        }
    }

    var isVisitrOnHold: Bool = false {
        didSet {
            connectView.operatorView.isVisitorOnHold = isVisitrOnHold

            if isVisitrOnHold {
                secondLabel.text = style.onHoldStyle.onHoldText
                secondLabel.accessibilityLabel = style.onHoldStyle.onHoldText
                connectView.statusView.setSecondText(style.onHoldStyle.onHoldText, animated: false)
                connectView.statusView.setStyle(style.connect.onHold)
            } else {
                secondLabel.text = callDuration
                secondLabel.accessibilityLabel = callDuration
                connectView.statusView.setSecondText(callDuration, animated: false)
                connectView.statusView.setStyle(style.connect.connected)
            }

            if case .video = mode {
                connectView.isHidden = !isVisitrOnHold
                topStackView.isHidden = isVisitrOnHold
                remoteVideoView.isHidden = isVisitrOnHold
            }

            bottomLabel.text = isVisitrOnHold
                ? style.onHoldStyle.descriptionText
                : nil

            bottomLabel.isHidden = !isVisitrOnHold
            localVideoView.label.isHidden = !isVisitrOnHold
        }
    }

    lazy var operatorNameLabel: UILabel = {
        let label = UILabel()
        label.accessibilityHint = style.accessibility.operatorNameHint
        return label
    }()

    lazy var secondLabel = UILabel()

    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let buttonBar: CallButtonBar

    lazy var localVideoView: VideoStreamView = {
        let streamView = VideoStreamView(
            .local,
            flipCameraButtonStyle: style.flipCameraButtonStyle
        )
        streamView.accessibilityLabel = style.accessibility.localVideoLabel
        return streamView
    }()

    lazy var remoteVideoView: VideoStreamView = {
        let streamView = VideoStreamView(
            .remote,
            flipCameraButtonStyle: style.flipCameraButtonStyle
        )
        // Consider to provide Operator name instead of generic 'Operator's'
        streamView.accessibilityLabel = style.accessibility.remoteVideoLabel
        return streamView
    }()

    var callButtonTapped: ((CallButton.Kind) -> Void)?
    var flipCameraAccessibilityLabelWithTap: VideoStreamView.FlipCameraAccLabelWithTap? {
        didSet {
            localVideoView.flipCameraAccessibilityLabelWithTap = flipCameraAccessibilityLabelWithTap
        }
    }
    let topStackView = UIStackView()

    private let style: CallStyle
    private var mode: Mode = .audio
    private var hideBarsWorkItem: DispatchWorkItem?
    private var headerTopConstraint: NSLayoutConstraint!
    private var buttonBarBottomConstraint: NSLayoutConstraint!
    private var remoteVideoViewHeightConstraint: NSLayoutConstraint!
    private var remoteVideoViewWidthConstraint: NSLayoutConstraint!
    private let kBarsHideDelay: TimeInterval = 3.2
    private var localVideoBounds: CGRect {
        let x = safeAreaInsets.left + 10
        let y = header.frame.maxY + 10
        let width = frame.width - safeAreaInsets.left - safeAreaInsets.right - 2 * 10
        let height = buttonBar.frame.minY - header.frame.maxY - 2 * 10

        return CGRect(x: x, y: y, width: width, height: height)
    }
    private let environment: Environment

    var props: Props

    init(
        with style: CallStyle,
        environment: Environment,
        props: Props
    ) {
        self.style = style
        self.environment = environment
        self.buttonBar = CallButtonBar(with: style.buttonBar)
        self.props = props
        super.init(
            with: style,
            layout: .call,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen
            ),
            headerProps: props.header
        )
        setup()
        layout()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustForCurrentOrientation()
        adjustLocalVideoFrameAfterLayout()
    }

    override func setup() {
        accessibilityIdentifier = "call_root_view"

        topStackView.axis = .vertical
        topStackView.spacing = 8
        topStackView.addArrangedSubviews([operatorNameLabel, secondLabel])

        operatorNameLabel.font = style.operatorNameFont
        operatorNameLabel.textColor = style.operatorNameColor
        operatorNameLabel.textAlignment = .center
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: operatorNameLabel
        )

        secondLabel.font = style.durationFont
        secondLabel.textColor = style.durationColor
        secondLabel.textAlignment = .center
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: secondLabel
        )

        topLabel.text = style.topText
        topLabel.font = style.topTextFont
        topLabel.textColor = style.topTextColor
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .center
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: topLabel
        )

        bottomLabel.text = style.bottomText
        bottomLabel.font = style.bottomTextFont
        bottomLabel.textColor = style.bottomTextColor
        bottomLabel.numberOfLines = 0
        bottomLabel.textAlignment = .center
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: bottomLabel
        )

        buttonBar.buttonTapped = { [weak self] in
            self?.callButtonTapped?($0)
            self?.hideLandscapeBarsAfterDelay()
        }

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

        if let backButton = style.header.backButton {
            header.backButton?.accessibilityLabel = backButton.accessibility.label
            header.backButton?.accessibilityHint = backButton.accessibility.hint
        }
    }

    func switchTo(_ mode: Mode) {
        self.mode = mode

        switch mode {
        case .audio:
            connectView.isHidden = false
            topStackView.isHidden = true
            remoteVideoView.isHidden = true
            localVideoView.isHidden = true
        case .video:
            connectView.isHidden = !isVisitrOnHold
            topStackView.isHidden = isVisitrOnHold
            remoteVideoView.isHidden = isVisitrOnHold
            localVideoView.isHidden = false
            if currentOrientation.isLandscape {
                hideLandscapeBarsAfterDelay()
            }
        case .upgrading:
            connectView.isHidden = false
            topStackView.isHidden = true
            remoteVideoView.isHidden = true
            localVideoView.isHidden = true
        }

        adjustForCurrentOrientation()
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)

        if isVisitrOnHold {
            connectView.statusView.setSecondText(style.onHoldStyle.onHoldText, animated: false)
        }
    }

    func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        if orientation.isLandscape {
            if mode == .video {
                hideLandscapeBarsAfterDelay()
            }
        } else {
            showBars(duration: duration)
        }

        buttonBar.adjustStackConstraints()
    }

    func didRotate() {
        adjustLocalVideoFrameAfterOrientationChange()
    }

    func checkBarsOrientation() {
        guard mode == .video else { return }

        if currentOrientation.isLandscape {
            hideLandscapeBarsAfterDelay()
        } else {
            headerTopConstraint.constant = 0
            buttonBarBottomConstraint.constant = 0
        }
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        constraints += effectView.layoutInSuperview()

        addSubview(remoteVideoView)
        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        constraints += remoteVideoView.centerXAnchor.constraint(equalTo: centerXAnchor)
        constraints += remoteVideoView.centerYAnchor.constraint(equalTo: centerYAnchor)
        remoteVideoViewHeightConstraint = remoteVideoView.match(.height, value: 0).first
        remoteVideoViewWidthConstraint = remoteVideoView.match(.width, value: 0).first
        constraints += [remoteVideoViewHeightConstraint, remoteVideoViewWidthConstraint].compactMap { $0 }

        addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        headerTopConstraint = header.layoutInSuperview(edges: .top).first
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
        buttonBarBottomConstraint = buttonBar.layoutInSuperview(edges: .bottom).first
        constraints += [buttonBarBottomConstraint].compactMap { $0 }
        constraints += buttonBar.layoutInSuperview(edges: .horizontal)

        addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.adjustsFontSizeToFitWidth = true
        bottomLabel.setContentCompressionResistancePriority(
            .fittingSizeLevel,
            for: .vertical
        )
        constraints += bottomLabel.bottomAnchor.constraint(equalTo: buttonBar.topAnchor, constant: -32)
        constraints += bottomLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85)
        constraints += bottomLabel.centerXAnchor.constraint(equalTo: centerXAnchor)

        addSubview(localVideoView)

        adjustForCurrentOrientation()
        switchTo(mode)
    }

    private func adjustForCurrentOrientation() {
        func createNewProps(
            with props: Header.Props,
            newEffect: Header.Effect
        ) -> Header.Props {
            .init(
                title: props.title,
                effect: props.effect,
                endButton: props.endButton,
                backButton: props.backButton,
                closeButton: props.closeButton,
                endScreenshareButton: props.endScreenshareButton,
                style: props.style
            )
        }

        if currentOrientation.isLandscape {
            if mode == .video {
                header.props = createNewProps(with: header.props, newEffect: .blur)
                buttonBar.effect = .blur
            }
            topStackView.alpha = 0.0
            bottomLabel.alpha = 0.0
        } else {
            header.props = createNewProps(with: header.props, newEffect: .none)
            buttonBar.effect = .none
            topStackView.alpha = 1.0
            bottomLabel.alpha = 1.0
        }

        adjustVideoViews()
    }

    private func adjustVideoViews() {
        adjustRemoteVideoView()
    }

    private func adjustRemoteVideoView() {
        remoteVideoViewHeightConstraint?.constant = frame.size.height
        remoteVideoViewWidthConstraint?.constant = frame.size.width
    }

    private func showBars(duration: TimeInterval) {
        layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            self.headerTopConstraint.constant = 0
            self.buttonBarBottomConstraint.constant = 0
            self.layoutIfNeeded()
        }
    }

    private func hideBars(duration: TimeInterval) {
        layoutIfNeeded()
        let newHeaderConstraint = -header.frame.size.height + safeAreaInsets.top
        UIView.animate(withDuration: duration) {
            self.headerTopConstraint.constant = newHeaderConstraint
            self.buttonBarBottomConstraint.constant = self.buttonBar.frame.size.height
            self.layoutIfNeeded()
        }
    }

    private func hideLandscapeBars() {
        guard currentOrientation.isLandscape else { return }
        hideBars(duration: 0.3)
    }

    private func hideLandscapeBarsAfterDelay() {
        guard mode == .video else { return }
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + kBarsHideDelay) {
            self.hideLandscapeBars()
        }
    }

    @objc private func tap() {
        if currentOrientation.isLandscape {
            showBars(duration: 0.3)
            hideLandscapeBarsAfterDelay()
        }
    }
}
// swiftlint:enable type_body_length

// MARK: Local Video

extension CallView {
    static let localVideoSideMultiplier = 0.3

    private func setLocalVideoFrame(isVisible: Bool) {
        if isVisible {
            let screenBounds = environment.uiScreen.bounds()

            let size = Self.localVideoSize(
                for: environment.uiDevice.orientation(),
                from: screenBounds.size
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

    private func adjustLocalVideoFrameAfterOrientationChange() {
        let screenBounds = environment.uiScreen.bounds()

        let newSize = Self.localVideoSize(
            for: environment.uiDevice.orientation(),
            from: screenBounds.size
        )

        localVideoView.frame = CGRect(
            origin: CGPoint(
                x: localVideoBounds.maxX - newSize.width,
                y: localVideoBounds.maxY - newSize.height
            ),
            size: newSize
        )
    }

    private func adjustLocalVideoFrameAfterPanGesture(translation: CGPoint) {
        var frame = localVideoView.frame

        frame.origin.x += translation.x
        frame.origin.y += translation.y

        localVideoView.frame = frame

        if localVideoBounds.contains(frame) {
            localVideoView.frame = frame
        }
    }

    private func adjustLocalVideoFrameAfterLayout() {
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

    static func localVideoSize(
        for orientation: UIDeviceOrientation,
        from screenSize: CGSize
    ) -> CGSize {
        let width: CGFloat
        let height: CGFloat

        if orientation.isLandscape {
            width = max(screenSize.width, screenSize.height)
            height = min(screenSize.width, screenSize.height)
        } else {
            width = min(screenSize.width, screenSize.height)
            height = max(screenSize.width, screenSize.height)
        }

        return CGSize(
            width: width * Self.localVideoSideMultiplier,
            height: height * Self.localVideoSideMultiplier
        )
    }
}

extension CallView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var uiDevice: UIKitBased.UIDevice
    }
}
