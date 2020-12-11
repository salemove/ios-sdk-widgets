import UIKit

class QueueView: UIView {
    enum State: Equatable {
        case initial
        case waiting
        case connecting(name: String)
        case connected(name: String)
    }

    let operatorView: QueueOperatorView

    private let style: QueueStyle
    private var state: State = .initial
    private let statusView = QueueStatusView()
    private let stackView = UIStackView()
    private let kOperatorNamePlaceholder = "{operatorName}"
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
            statusView.setText1(style.waiting.text1,
                                text2: style.waiting.text2,
                                animated: false)
            statusView.setStyle(style.waiting)
            stackView.setCustomSpacing(0, after: operatorView)
            show(animated: animated)
        case .connecting(let name):
            let text1 = style.connecting.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                     with: name)
            statusView.setText1(text1,
                                text2: nil,
                                animated: animated)
            statusView.setStyle(style.connecting)
            stackView.setCustomSpacing(0, after: operatorView)
            startConnectTimer()
        case .connected(let name):
            operatorView.stopAnimating(animated: animated)
            let text1 = style.connected.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                    with: name)
            let text2 = style.connected.text2?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                    with: name)
            statusView.setText1(text1,
                                text2: text2,
                                animated: animated)
            statusView.setStyle(style.connected)
            stackView.setCustomSpacing(10, after: operatorView)
        }
    }

    private func show(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.stackView.transform = .identity
                       }, completion: nil)
    }

    private func hide(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.stackView.transform = CGAffineTransform(scaleX: 0, y: 0)
                       }, completion: nil)
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.addArrangedSubviews([operatorView, statusView])

        setState(.initial, animated: false)
    }

    private func layout() {
        //autoSetDimension(.height, toSize: 200)

        addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .top)
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        stackView.autoAlignAxis(toSuperviewAxis: .vertical)
    }
}

private extension QueueView {
    private func startConnectTimer() {
        guard connectTimer == nil else { return }
        connectTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            switch self.state {
            case .connecting:
                self.connectCounter += 1
                self.statusView.setText2("\(self.connectCounter)")
            default:
                self.connectTimer?.invalidate()
                self.connectTimer = nil
            }
        }
    }
}
