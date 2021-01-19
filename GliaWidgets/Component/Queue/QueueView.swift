import UIKit

class QueueView: UIView {
    enum State: Equatable {
        case initial
        case waiting
        case connecting
        case connected(name: String?, imageUrl: String?)
    }

    let operatorView: QueueOperatorView

    private let style: QueueStyle
    private var state: State = .initial
    private let statusView = QueueStatusView()
    private var connectTimer: Timer?
    private var connectCounter: Int = 0

    init(with style: QueueStyle) {
        self.style = style
        self.operatorView = QueueOperatorView(with: style.queueOperator)
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
        case .initial:
            hide(animated: animated)
        case .waiting:
            operatorView.startAnimating(animated: animated)
            statusView.setFirstText(style.waiting.firstText, animated: false)
            statusView.setSecondText(style.waiting.secondText, animated: false)
            statusView.setStyle(style.waiting)
            show(animated: animated)
        case .connecting:
            let firstText = style.connecting.firstText
            statusView.setFirstText(firstText, animated: animated)
            statusView.setSecondText(nil, animated: animated)
            statusView.setStyle(style.connecting)
            startConnectTimer()
        case .connected(let name, let imageUrl):
            operatorView.stopAnimating(animated: animated)
            operatorView.imageView.setImage(fromUrl: imageUrl, animated: true)
            if let name = name {
                let firstText = style.connected.firstText?.withOperatorName(name)
                let secondText = style.connected.secondText?.withOperatorName(name)
                statusView.setFirstText(firstText, animated: animated)
                statusView.setSecondText(secondText, animated: animated)
            } else {
                statusView.setFirstText(nil, animated: animated)
                statusView.setFirstText(nil, animated: animated)
            }
            statusView.setStyle(style.connected)
        }
    }

    private func show(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.transform = .identity
                       }, completion: nil)
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
    }

    private func setup() {
        setState(.initial, animated: false)
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

private extension QueueView {
    private func startConnectTimer() {
        guard connectTimer == nil else { return }
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
}
