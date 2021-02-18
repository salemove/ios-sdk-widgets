import UIKit

class ConnectView: UIView {
    enum State: Equatable {
        case none
        case queue
        case connecting(name: String?, imageUrl: String?)
        case connected(name: String?, imageUrl: String?)
    }

    let operatorView: ConnectOperatorView
    let statusView = ConnectStatusView()

    private let style: ConnectStyle
    private var state: State = .none
    private var connectTimer: Timer?
    private var connectCounter: Int = 0
    private var isShowing = false

    init(with style: ConnectStyle) {
        self.style = style
        self.operatorView = ConnectOperatorView(with: style.connectOperator)
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: State, animated: Bool) {
        self.state = state

        switch state {
        case .none:
            stopConnectTimer()
            hide(animated: animated)
        case .queue:
            stopConnectTimer()
            operatorView.startAnimating(animated: animated)
            statusView.setFirstText(style.queue.firstText, animated: false)
            statusView.setSecondText(style.queue.secondText, animated: false)
            statusView.setStyle(style.queue)
            show(animated: animated)
        case .connecting(let name, let imageUrl):
            operatorView.startAnimating(animated: animated)
            operatorView.imageView.setImage(fromUrl: imageUrl, animated: true)
            let firstText = style.connecting.firstText?.withOperatorName(name)
            statusView.setFirstText(firstText, animated: animated)
            statusView.setSecondText(nil, animated: animated)
            statusView.setStyle(style.connecting)
            startConnectTimer()
            show(animated: animated)
        case .connected(let name, let imageUrl):
            stopConnectTimer()
            operatorView.stopAnimating(animated: animated)
            operatorView.imageView.setImage(fromUrl: imageUrl, animated: true)
            if let name = name {
                let firstText = style.connected.firstText?.withOperatorName(name)
                let secondText = style.connected.secondText?
                    .withOperatorName(name)
                    .withCallDuration("00:00")
                statusView.setFirstText(firstText, animated: animated)
                statusView.setSecondText(secondText, animated: animated)
            } else {
                statusView.setFirstText(nil, animated: animated)
                statusView.setFirstText(nil, animated: animated)
            }
            statusView.setStyle(style.connected)
            show(animated: animated)
        }
    }

    private func show(animated: Bool) {
        guard !isShowing else { return }
        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.transform = .identity
                       }, completion: nil)
        isShowing = true
    }

    private func hide(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0, y: 0)
                       }, completion: nil)
        isShowing = false
    }

    private func setup() {
        setState(.none, animated: false)
    }

    private func layout() {
        addSubview(operatorView)
        operatorView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        operatorView.autoPinEdge(toSuperviewEdge: .left)
        operatorView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(statusView)
        statusView.autoPinEdge(.top, to: .bottom, of: operatorView, withOffset: 10)
        statusView.autoPinEdge(toSuperviewEdge: .left)
        statusView.autoPinEdge(toSuperviewEdge: .right)
        statusView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }
}

private extension ConnectView {
    private func startConnectTimer() {
        stopConnectTimer()
        connectCounter = 0
        connectTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            switch self.state {
            case .connecting:
                self.connectCounter += 1
                self.statusView.setSecondText("\(self.connectCounter)", animated: true)
            default:
                self.connectTimer?.invalidate()
                self.connectTimer = nil
            }
        }
    }

    private func stopConnectTimer() {
        connectTimer?.invalidate()
        connectTimer = nil
    }
}
