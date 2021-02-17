import UIKit

class CallView: EngagementView {
    enum Mode {
        case audio
        case video
        case upgrading
    }

    let operatorNameLabel = UILabel()
    let durationLabel = UILabel()
    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let buttonBar: CallButtonBar
    let localVideoView = VideoStreamView(.local)
    let remoteVideoView = VideoStreamView(.remote)
    var chatTapped: (() -> Void)?
    var callButtonTapped: ((CallButton.Kind) -> Void)?

    private let style: CallStyle
    private var mode: Mode = .audio
    private let topView = UIView()
    private let topStackView = UIStackView()
    private var hideBarsWorkItem: DispatchWorkItem?
    private var headerTopConstraint: NSLayoutConstraint!
    private var buttonBarBottomConstraint: NSLayoutConstraint!
    private var localVideoViewTopConstraint: NSLayoutConstraint!
    private var localVideoViewRightConstraint: NSLayoutConstraint!
    private var localVideoViewHeightConstraint: NSLayoutConstraint!
    private var remoteVideoViewHeightConstraint: NSLayoutConstraint!
    private let kLocalVideoViewDefaultHeight: CGFloat = 186
    private let kRemoteVideoViewPortraitHeightMultiplier: CGFloat = 0.3
    private let kRemoteVideoViewLandscapeHeightMultiplier: CGFloat = 1.0
    private let kBarsHideDelay: TimeInterval = 3.0

    init(with style: CallStyle) {
        self.style = style
        self.buttonBar = CallButtonBar(with: style.buttonBar)
        super.init(with: style)
        setup()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustForCurrentOrientation()
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
            connectView.isHidden = true
            topStackView.isHidden = false
            remoteVideoView.isHidden = false
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
                hideBars(duration: duration)
            }
        } else {
            if mode == .video {
                showBars( duration: duration)
            }
        }
    }

    private func setup() {
        topStackView.axis = .vertical
        topStackView.spacing = 8
        topStackView.addArrangedSubviews([operatorNameLabel, durationLabel])

        operatorNameLabel.font = style.operatorNameFont
        operatorNameLabel.textColor = style.operatorNameColor
        operatorNameLabel.textAlignment = .center

        durationLabel.font = style.durationFont
        durationLabel.textColor = style.durationColor
        durationLabel.textAlignment = .center

        topLabel.text = style.topText
        topLabel.font = style.topTextFont
        topLabel.textColor = style.topTextColor
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .center

        bottomLabel.text = style.bottomText
        bottomLabel.font = style.bottomTextFont
        bottomLabel.textColor = style.bottomTextColor
        bottomLabel.numberOfLines = 0
        bottomLabel.textAlignment = .center

        buttonBar.buttonTapped = { [weak self] in
            self?.callButtonTapped?($0)
            self?.hideLandscapeBarsAfterDelay()
        }

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tap))
        addGestureRecognizer(tapRecognizer)
    }

    private func layout() {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(remoteVideoView)
        remoteVideoView.autoAlignAxis(toSuperviewAxis: .horizontal)
        remoteVideoView.autoPinEdge(toSuperviewEdge: .left)
        remoteVideoView.autoPinEdge(toSuperviewEdge: .right)
        remoteVideoViewHeightConstraint = remoteVideoView.autoSetDimension(.height, toSize: 0)

        addSubview(localVideoView)
        localVideoViewTopConstraint = localVideoView.autoPinEdge(toSuperviewEdge: .top)
        localVideoViewRightConstraint = localVideoView.autoPinEdge(toSuperviewEdge: .right)
        localVideoViewHeightConstraint = localVideoView.autoSetDimension(.height,
                                                                         toSize: kLocalVideoViewDefaultHeight)
        localVideoView.autoMatch(.width, to: .height, of: localVideoView, withMultiplier: 0.7)

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
        adjustLocalVideoView()
    }

    private func adjustRemoteVideoView() {
        if currentOrientation.isLandscape {
            remoteVideoViewHeightConstraint.constant = frame.size.height * kRemoteVideoViewLandscapeHeightMultiplier
        } else {
            remoteVideoViewHeightConstraint.constant = frame.size.height * kRemoteVideoViewPortraitHeightMultiplier
        }
    }

    private func adjustLocalVideoView() {
        if currentOrientation.isLandscape {
            localVideoViewTopConstraint.constant = 20
            localVideoViewRightConstraint.constant = -20
        } else {
            let kTopInset: CGFloat = 10
            let kBottomInset: CGFloat = 10
            let kRightInset: CGFloat = -10
            let top = header.frame.maxY + kTopInset
            let height = remoteVideoView.frame.minY - header.frame.maxY - (kTopInset + kBottomInset)
            localVideoViewHeightConstraint.constant = height > 0 ? height : 0
            localVideoViewTopConstraint.constant = top
            localVideoViewRightConstraint.constant = kRightInset
        }
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
        UIView.animate(withDuration: duration) {
            self.headerTopConstraint.constant = -self.header.frame.size.height
            self.buttonBarBottomConstraint.constant = self.buttonBar.frame.size.height
            self.layoutIfNeeded()
        }
    }

    private func hideLandscapeBars() {
        guard currentOrientation.isLandscape else { return }
        hideBars(duration: 0.3)
    }

    private func hideLandscapeBarsAfterDelay() {
        hideBarsWorkItem?.cancel()
        let hideBarsWorkItem = DispatchWorkItem { self.hideLandscapeBars() }
        self.hideBarsWorkItem = hideBarsWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + kBarsHideDelay,
                                      execute: hideBarsWorkItem)
    }

    @objc private func chatTap() {
        chatTapped?()
    }

    @objc private func tap() {
        if currentOrientation.isLandscape {
            showBars(duration: 0.3)
            hideLandscapeBarsAfterDelay()
        }
    }
}
