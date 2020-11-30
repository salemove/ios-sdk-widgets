import UIKit

class ChatOperatorView: View {
    struct ChatOperator {
        let name: String
        let image: UIImage?
    }

    enum State {
        case enqueued
        case connecting(ChatOperator)
        case connected(ChatOperator)
    }

    private let style: ChatOperatorStyle
    private let imageView: ChatOperatorImageView
    private let statusView = ChatOperatorStatusView()
    private var state: State = .enqueued {
        didSet { setState(state) }
    }
    private let stackView = UIStackView()
    private let kOperatorNamePlaceholder = "{operatorName}"

    init(with style: ChatOperatorStyle) {
        self.style = style
        self.imageView = ChatOperatorImageView(with: style.image)
        super.init()
        setup()
        layout()
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 0
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

    private func setState(_ state: State) {
        switch state {
        case .enqueued:
            imageView.image = nil
            imageView.isAnimating = true
            statusView.label1.text = style.enqueued.text1
            statusView.label2.text = style.enqueued.text2
        case .connecting(let chatOperator):
            imageView.image = chatOperator.image
            imageView.isAnimating = true
            statusView.label1.text = style.enqueued.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                                with: chatOperator.name)
        case .connected(let chatOperator):
            imageView.image = chatOperator.image
            imageView.isAnimating = false
            statusView.label1.text = style.enqueued.text1?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                                with: chatOperator.name)
            statusView.label2.text = style.enqueued.text2?.replacingOccurrences(of: kOperatorNamePlaceholder,
                                                                                with: chatOperator.name)
        }

        let stateStyle = style(for: state)
        statusView.label1.font = stateStyle.text1Font
        statusView.label1.textColor = stateStyle.text1FontColor
        statusView.label2.font = stateStyle.text2Font
        statusView.label2.textColor = stateStyle.text2FontColor
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
