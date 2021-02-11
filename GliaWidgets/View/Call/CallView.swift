import UIKit

class CallView: EngagementView {
    let infoLabel = UILabel()
    let buttonBar: CallButtonBar
    let localVideoView = VideoStreamView(.local)
    let remoteVideoView = VideoStreamView(.remote)
    var chatTapped: (() -> Void)?

    private let style: CallStyle

    init(with style: CallStyle) {
        self.style = style
        self.buttonBar = CallButtonBar(with: style.buttonBar)
        super.init(with: style)
        setup()
        layout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
    }

    private func setup() {
        infoLabel.text = style.infoText
        infoLabel.font = style.infoTextFont
        infoLabel.textColor = style.infoTextColor
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        adjustForOrientation()
    }

    private func layout() {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

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
    }

    private func adjustForOrientation() {
        let isLandscape = [.landscapeLeft, .landscapeRight]
            .contains(UIApplication.shared.statusBarOrientation)
        infoLabel.isHidden = isLandscape
    }

    @objc private func chatTap() {
        chatTapped?()
    }

    @objc private func orientationChanged() {
        adjustForOrientation()
    }
}
