import UIKit

class CallView: EngagementView {
    enum Mode {
        case audio
        case video
    }

    let operatorNameLabel = UILabel()
    let durationLabel = UILabel()
    let infoLabel = UILabel()
    let buttonBar: CallButtonBar
    let localVideoView = VideoStreamView(.local)
    let remoteVideoView = VideoStreamView(.remote)
    var chatTapped: (() -> Void)?

    private let style: CallStyle
    private var mode: Mode = .audio
    private let topView = UIView()
    private let topStackView = UIStackView()
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

    func switchTo(_ mode: Mode, animated: Bool) {
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
        }
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
    }

    func adjustForOrientation(_ orientation: UIInterfaceOrientation, animated: Bool, duration: TimeInterval) {
        let isLandscape = [.landscapeLeft, .landscapeRight]
            .contains(orientation)

        remoteVideoViewHeightMultiplier.constant = isLandscape
            ? kRemoteVideoViewLandscapeHeightMultiplier
            : kRemoteVideoViewPortraitHeightMultiplier

        UIView.animate(withDuration: animated ? duration : 0.0) {
            self.topStackView.alpha = isLandscape ? 0.0 : 1.0
            self.infoLabel.alpha = isLandscape ? 0.0 : 1.0
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

        infoLabel.text = style.infoText
        infoLabel.font = style.infoTextFont
        infoLabel.textColor = style.infoTextColor
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
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
        localVideoViewHeightConstraint = localVideoView.autoSetDimension(.height,
                                                                         toSize: kLocalVideoViewDefaultHeight)
        localVideoView.autoPinEdge(toSuperviewSafeArea: .right, withInset: 10)
        localVideoView.autoMatch(.width, to: .height, of: localVideoView, withMultiplier: 0.6)

        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(connectView)
        connectView.autoPinEdge(.top, to: .bottom, of: header)
        connectView.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(topStackView)
        topStackView.autoPinEdge(.top, to: .bottom, of: header, withOffset: 50)
        topStackView.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(buttonBar)
        buttonBar.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0),
                                                  excludingEdge: .top)

        addSubview(infoLabel)
        infoLabel.autoPinEdge(.bottom, to: .top, of: buttonBar, withOffset: -38)
        infoLabel.autoMatch(.width, to: .width, of: self, withMultiplier: 0.6)
        infoLabel.autoAlignAxis(toSuperviewAxis: .vertical)

        adjustLocalVideoView()
        switchTo(mode, animated: false)
    }

    private func adjustLocalVideoView() {
        let kTopGap: CGFloat = 10
        let kBottomGap: CGFloat = 10
        // TODO: check orientation - set default height for landscape
        let y = header.frame.maxY + kTopGap
        let height = remoteVideoView.frame.minY - header.frame.maxY - kTopGap - kBottomGap
        localVideoView.frame.origin.y = y
        localVideoViewHeightConstraint.constant = height
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}
