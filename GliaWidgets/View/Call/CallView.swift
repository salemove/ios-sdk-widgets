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
    private var remoteVideoViewHeightMultiplier: NSLayoutConstraint!
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
        adjustForOrientation()
    }

    func setMode(_ mode: Mode, animated: Bool) {
        self.mode = mode

        switch mode {
        case .audio:
            break
        case .video:
            setConnectState(.none, animated: animated)
        }
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
    }

    private func setup() {
        topStackView.axis = .vertical

        operatorNameLabel.font = style.operatorNameFont
        operatorNameLabel.textColor = style.operatorNameColor

        durationLabel.font = style.durationFont
        durationLabel.textColor = style.durationColor

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
        localVideoView.autoSetDimensions(to: CGSize(width: 100, height: 180))
        localVideoView.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        localVideoView.autoPinEdge(toSuperviewEdge: .top, withInset: 60)

        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(connectView)
        connectView.autoPinEdge(.top, to: .bottom, of: header)
        connectView.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(buttonBar)
        buttonBar.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0),
                                                  excludingEdge: .top)

        addSubview(infoLabel)
        infoLabel.autoPinEdge(.bottom, to: .top, of: buttonBar, withOffset: -38)
        infoLabel.autoMatch(.width, to: .width, of: self, withMultiplier: 0.6)
        infoLabel.autoAlignAxis(toSuperviewAxis: .vertical)

        setMode(mode, animated: false)
    }

    private func adjustForOrientation() {
        let isLandscape = [.landscapeLeft, .landscapeRight]
            .contains(UIApplication.shared.statusBarOrientation)
        remoteVideoViewHeightMultiplier.constant = isLandscape
            ? kRemoteVideoViewLandscapeHeightMultiplier
            : kRemoteVideoViewPortraitHeightMultiplier
        infoLabel.isHidden = isLandscape
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}
