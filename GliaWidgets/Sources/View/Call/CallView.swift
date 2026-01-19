import UIKit
import SwiftUI

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
            guard !state.isOnHold else { return }
            updateConnectViewState()
        }
    }

    var operatorName: String?
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
        streamView.accessibilityLabel = style.accessibility.remoteVideoLabel
        return streamView
    }()

    var callButtonTapped: ((CallButton.Kind) -> Void)?
    var flipCameraAccessibilityLabelWithTap: VideoStreamView.FlipCameraAccLabelWithTap? {
        didSet {
            localVideoView.flipCameraAccessibilityLabelWithTap = flipCameraAccessibilityLabelWithTap
        }
    }
    private let style: CallStyle
    private var mode: Mode = .audio
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

    private(set) var state: EngagementState
    private lazy var connectView: CallConnectViewHost = {
        CallConnectViewHost(
            connectStyle: style.connect,
            callStyle: style,
            durationHint: style.connect.connected.accessibility.secondTextHint,
            imageCache: environment.imageViewCache
        )
    }()
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
        self.state = .initial
        super.init(
            with: style,
            environment: .create(with: environment),
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

        topLabel.text = style.topText
        topLabel.font = style.topTextFont
        topLabel.textColor = style.topTextColor
        topLabel.numberOfLines = 0
        topLabel.textAlignment = style.topTextAlignment
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: topLabel
        )

        bottomLabel.text = style.bottomText
        bottomLabel.font = style.bottomTextFont
        bottomLabel.textColor = style.bottomTextColor
        bottomLabel.numberOfLines = 0
        bottomLabel.textAlignment = style.bottomTextAlignment
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
        connectView.setMode(mode)
        updateVisibilityForCurrentState()

        if mode == .video, currentOrientation.isLandscape {
            hideLandscapeBarsAfterDelay()
        }

        adjustForCurrentOrientation()
    }

    func setConnectState(_ state: EngagementState, animated: Bool) {
        self.state = state
        updateConnectViewState()
        updateVisibilityForCurrentState()
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

    private func updateConnectViewState() {
        let duration = state.isOnHold ? nil : callDuration
        connectView.setState(state, durationText: duration)
    }

    func setVisitorOnHold(_ isOnHold: Bool) {
        state = state.applyingOnHold(
            isOnHold,
            onHoldText: style.onHoldStyle.onHoldText,
            descriptionText: style.onHoldStyle.descriptionText,
            operatorNameOverride: operatorName
        )
        bottomLabel.text = isOnHold ? style.onHoldStyle.descriptionText : nil
        bottomLabel.isHidden = !isOnHold
        localVideoView.label.isHidden = !isOnHold
        updateConnectViewState()
        updateVisibilityForCurrentState()
    }

    private func updateVisibilityForCurrentState() {
        switch mode {
        case .audio, .upgrading:
            remoteVideoView.isHidden = true
            localVideoView.isHidden = true
        case .video:
            remoteVideoView.isHidden = state.isOnHold
            localVideoView.isHidden = false
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
        constraints += connectView.topAnchor.constraint(equalTo: header.bottomAnchor)
        constraints += connectView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
        constraints += connectView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        constraints += connectView.heightAnchor.constraint(greaterThanOrEqualToConstant: 265)

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
                style: props.style
            )
        }

        if currentOrientation.isLandscape {
            if mode == .video {
                header.props = createNewProps(with: header.props, newEffect: .blur)
                buttonBar.effect = .blur
            }
            bottomLabel.alpha = 0.0
        } else {
            header.props = createNewProps(with: header.props, newEffect: .none)
            buttonBar.effect = .none
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

extension CallView: MediaQualityIndicatorHost {
    var mediaQualityIndicatorContainerView: UIView { self }
    var mediaQualityIndicatorTopAnchor: NSLayoutYAxisAnchor { header.bottomAnchor }
}
