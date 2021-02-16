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

    private let style: CallStyle
    private var mode: Mode = .audio
    private let topView = UIView()
    private let topStackView = UIStackView()
    private var localVideoViewTopConstraint: NSLayoutConstraint!
    private var localVideoViewRightConstraint: NSLayoutConstraint!
    private var localVideoViewHeightConstraint: NSLayoutConstraint!
    private var remoteVideoViewHeightMultiplier: NSLayoutConstraint!
    private let kLocalVideoViewDefaultHeight: CGFloat = 186
    private let kRemoteVideoViewPortraitHeightMultiplier: CGFloat = 0.3
    private let kRemoteVideoViewLandscapeHeightMultiplier: CGFloat = 1.0

    init(with style: CallStyle) {
        self.style = style
        self.buttonBar = CallButtonBar(with: style.buttonBar)
        super.init(with: style)
        setup()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustLocalVideoView()
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
        case .upgrading:
            connectView.isHidden = false
            topStackView.isHidden = true
            remoteVideoView.isHidden = true
            localVideoView.isHidden = true
        }
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
    }

    func adjustForOrientation(_ orientation: UIInterfaceOrientation, animated: Bool, duration: TimeInterval) {
        let isLandscape = [.landscapeLeft, .landscapeRight].contains(orientation)

        if isLandscape {
            header.effect = .darkBlur
            buttonBar.effect = .darkBlur
            remoteVideoViewHeightMultiplier.constant = kRemoteVideoViewLandscapeHeightMultiplier
        } else {
            header.effect = .none
            buttonBar.effect = .none
            remoteVideoViewHeightMultiplier.constant = kRemoteVideoViewPortraitHeightMultiplier
        }

        UIView.animate(withDuration: animated ? duration : 0.0) {
            self.topStackView.alpha = isLandscape ? 0.0 : 1.0
            self.bottomLabel.alpha = isLandscape ? 0.0 : 1.0
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
    }

    private func layout() {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(remoteVideoView)
        remoteVideoView.autoCenterInSuperview()
        remoteVideoView.autoMatch(.width, to: .width, of: self)
        remoteVideoViewHeightMultiplier = remoteVideoView.autoMatch(.height,
                                                                    to: .height,
                                                                    of: self,
                                                                    withMultiplier: kRemoteVideoViewPortraitHeightMultiplier)

        addSubview(localVideoView)
        localVideoViewTopConstraint = localVideoView.autoPinEdge(toSuperviewEdge: .top)
        localVideoViewRightConstraint = localVideoView.autoPinEdge(toSuperviewEdge: .right)
        localVideoViewHeightConstraint = localVideoView.autoSetDimension(.height,
                                                                         toSize: kLocalVideoViewDefaultHeight)
        localVideoView.autoMatch(.width, to: .height, of: localVideoView, withMultiplier: 0.6)

        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

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
        buttonBar.autoPinEdgesToSuperviewEdges(with: .zero,
                                               excludingEdge: .top)

        addSubview(bottomLabel)
        bottomLabel.autoPinEdge(.bottom, to: .top, of: buttonBar, withOffset: -38)
        bottomLabel.autoMatch(.width, to: .width, of: self, withMultiplier: 0.6)
        bottomLabel.autoAlignAxis(toSuperviewAxis: .vertical)

        adjustForOrientation(currentOrientation, animated: false, duration: 0)
        adjustLocalVideoView()
        switchTo(mode)
    }

    private func adjustLocalVideoView() {localVideoView.backgroundColor = .lightGray
        if isLandscape {
            localVideoViewTopConstraint.constant = 20
            localVideoViewRightConstraint.constant = -20
        } else {
            let kTopInset: CGFloat = 10
            let kBottomInset: CGFloat = 10
            let height = remoteVideoView.frame.minY - header.frame.maxY - (kTopInset + kBottomInset)
            let top = header.frame.maxY + kTopInset
            localVideoViewHeightConstraint.constant = height
            localVideoViewTopConstraint.constant = top
            localVideoViewRightConstraint.constant = -10
        }
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}
