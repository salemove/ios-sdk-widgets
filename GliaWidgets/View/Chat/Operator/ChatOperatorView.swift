import UIKit

class ChatOperatorView: UIView {
    enum State {
        case initial
        case enqueued
        case connecting(name: String)
        case connected(name: String)
    }

    let imageView: ChatOperatorImageView

    private let style: ChatOperatorStyle
    private var state: State = .enqueued
    private let statusView = ChatOperatorStatusView()
    private let stackView = UIStackView()
    private let kOperatorNamePlaceholder = "{operatorName}"

    init(with style: ChatOperatorStyle) {
        self.style = style
        self.imageView = ChatOperatorImageView(with: style.image)
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
        case .enqueued:
            imageView.startAnimating(animated: false)
            statusView.setText1(style.enqueued.text1,
                                text2: style.enqueued.text2,
                                animated: false)
            statusView.setStyle(style.enqueued)
            stackView.setCustomSpacing(0, after: imageView)
            show(animated: true)
        case .connecting(let name):
            let text1 = style.connecting.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                     with: name)
            statusView.setText1(text1,
                                text2: nil,
                                animated: true)
            statusView.setStyle(style.connecting)
            stackView.setCustomSpacing(0, after: imageView)
        case .connected(let name):
            imageView.stopAnimating(animated: animated)
            let text1 = style.connected.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                    with: name)
            let text2 = style.connected.text2?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                    with: name)
            statusView.setText1(text1,
                                text2: text2,
                                animated: true)
            statusView.setStyle(style.connected)
            stackView.setCustomSpacing(10, after: imageView)
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

        setState(.initial, animated: false)
    }

    private func layout() {
        stackView.addArrangedSubviews([imageView, statusView])

        addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .top)
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        stackView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoAlignAxis(toSuperviewAxis: .vertical)
    }
}
