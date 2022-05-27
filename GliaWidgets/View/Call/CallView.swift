import UIKit

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
            } else {
                secondLabel.text = callDuration
                secondLabel.accessibilityLabel = callDuration
                connectView.statusView.setSecondText(callDuration, animated: false)
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

    lazy var secondLabel: UILabel = {
        let label = UILabel() 
//	MARK:
//		Need to take into account that this label is also used for visitor on hold,
//		by introducing separate accessibility hints for each state (on-hold/call-duration).
        label.accessibilityHint = style.accessibility.durationHint
        return label
    }()

    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let buttonBar: CallButtonBar

    lazy var localVideoView: VideoStreamView = {
        let streamView = VideoStreamView(.local)
        streamView.accessibilityLabel = style.accessibility.localVideoLabel
        return streamView
    }()

    lazy var remoteVideoView: VideoStreamView = {
        let streamView = VideoStreamView(.remote)
        // Consider to provide Operator name instead of generic 'Operator's'
        streamView.accessibilityLabel = style.accessibility.remoteVideoLabel
        return streamView
    }()

    var callButtonTapped: ((CallButton.Kind) -> Void)?
    let topStackView = UIStackView()

    private let style: CallStyle
    private var mode: Mode = .audio
    private let topView = UIView() // does not seem to be used
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

    init(
        with style: CallStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        self.buttonBar = CallButtonBar(with: style.buttonBar)
        super.init(
            with: style,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding
            )
        )
        setup()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustForCurrentOrientation()
        adjustLocalVideoFrameAfterLayout()
    }

    override func setup() {
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
        #warning("Provide localization for accessibility.")
        header.backButton.accessibilityLabel = "Back"
        header.backButton.accessibilityHint = "Activates minimize."
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
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(remoteVideoView)
        remoteVideoView.autoAlignAxis(toSuperviewAxis: .horizontal)
        remoteVideoView.autoAlignAxis(toSuperviewAxis: .vertical)
        remoteVideoViewHeightConstraint = remoteVideoView.autoSetDimension(.height, toSize: 0)
        remoteVideoViewWidthConstraint = remoteVideoView.autoSetDimension(.width, toSize: 0)

        addSubview(header)
        headerTopConstraint = header.autoPinEdge(toSuperviewEdge: .top)
        header.autoPinEdge(toSuperviewEdge: .left)
        header.autoPinEdge(toSuperviewEdge: .right)

        addSubview(topLabel)
        topLabel.autoPinEdge(.top, to: .bottom, of: header)
        topLabel.autoPinEdge(toSuperviewSafeArea: .left, withInset: 20)
        topLabel.autoPinEdge(toSuperviewSafeArea: .right, withInset: 20)

        addSubview(connectView)
        connectView.autoPinEdge(.top, to: .bottom, of: header)
        connectView.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(topStackView)
        topStackView.autoPinEdge(.top, to: .bottom, of: header, withOffset: 50)
        topStackView.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(buttonBar)
        buttonBarBottomConstraint = buttonBar.autoPinEdge(toSuperviewEdge: .bottom)
        buttonBar.autoPinEdge(toSuperviewEdge: .left)
        buttonBar.autoPinEdge(toSuperviewEdge: .right)

        addSubview(bottomLabel)
        bottomLabel.autoPinEdge(.bottom, to: .top, of: buttonBar, withOffset: -38)
        bottomLabel.autoMatch(.width, to: .width, of: self, withMultiplier: 0.6)
        bottomLabel.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(localVideoView)

        adjustForCurrentOrientation()
        switchTo(mode)
    }

    private func adjustForCurrentOrientation() {
        if currentOrientation.isLandscape {
            if mode == .video {
                header.effect = .blur
                buttonBar.effect = .blur
            }
            topStackView.alpha = 0.0
            bottomLabel.alpha = 0.0
        } else {
            header.effect = .none
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
        remoteVideoViewHeightConstraint.constant = frame.size.height
        remoteVideoViewWidthConstraint.constant = frame.size.width
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
        hideBarsWorkItem?.cancel()
        let hideBarsWorkItem = DispatchWorkItem { self.hideLandscapeBars() }
        self.hideBarsWorkItem = hideBarsWorkItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + kBarsHideDelay,
            execute: hideBarsWorkItem
        )
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
    private func setLocalVideoFrame(isVisible: Bool) {
        if isVisible {
            let screenSize: CGRect = UIScreen.main.bounds

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

    private func adjustLocalVideoFrameAfterOrientationChange() {
        let screenSize: CGRect = UIScreen.main.bounds

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
}

extension CallView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
    }
}
