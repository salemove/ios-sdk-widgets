import UIKit

class ChatOperatorView: UIView {
    enum State {
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
        case .enqueued:
            imageView.isAnimating = true
            statusView.setLabel1Text(style.enqueued.text1, animated: animated)
            statusView.setLabel2Text(style.enqueued.text2, animated: animated)
        case .connecting(let name):
            imageView.isAnimating = true
            let text1 = style.connecting.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                     with: name)
            statusView.setLabel1Text(text1, animated: animated)
            statusView.setLabel2Text(nil, animated: animated)
        case .connected(let name):
            imageView.isAnimating = false
            let text1 = style.connected.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                    with: name)
            let text2 = style.connected.text2?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                    with: name)
            statusView.setLabel1Text(text1, animated: animated)
            statusView.setLabel2Text(text2, animated: animated)
        }

        let stateStyle = style(for: state)
        statusView.label1.font = stateStyle.text1Font
        statusView.label1.textColor = stateStyle.text1FontColor
        statusView.label2.font = stateStyle.text2Font
        statusView.label2.textColor = stateStyle.text2FontColor
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 0

        setState(.enqueued, animated: false)
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

    private func style(for state: State) -> ChatOperatorStateStyle {
        switch state {
        case .enqueued:
            return style.enqueued
        case .connecting:
            return style.connecting
        case .connected:
            return style.connected
        }
    }
}
