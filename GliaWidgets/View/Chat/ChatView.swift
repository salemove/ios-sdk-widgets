class ChatView: View {
    let header: Header

    private let style: ChatStyle

    init(with style: ChatStyle) {
        self.style = style
        self.header = Header(with: style.header)
        super.init()
        setup()
        layout()
    }

    private func setup() {
        backgroundColor = style.backgroundColor
    }

    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        let operatorView = ChatOperatorView(with: style.chatOperator)
        operatorView.state = .enqueued
        addSubview(operatorView)
        operatorView.autoPinEdge(.top, to: .bottom, of: header, withOffset: 20)
        operatorView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        operatorView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        operatorView.autoAlignAxis(toSuperviewAxis: .vertical)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            operatorView.state = .connecting(ChatOperatorView.ChatOperator(name: "Kate", image: nil))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            operatorView.state = .connected(ChatOperatorView.ChatOperator(name: "Kate", image: nil))
        }

        let sent = SentChatMessageView(with: style.sentMessage)
        sent.appendContent(.text("Hi, I need help and guidance with moving money from one account to another"), animated: false)
        addSubview(sent)
        sent.autoPinEdge(toSuperviewEdge: .right)
        sent.autoPinEdge(.top, to: .bottom, of: operatorView, withOffset: 20)
        sent.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)

        let received = ReceivedChatMessageView(with: style.receivedMessage)
        received.appendContent(.text("Hi, Roger! I’d be glad to help you out. Could you specify the accounts that you want to use."), animated: false)
        addSubview(received)
        received.autoPinEdge(toSuperviewEdge: .left)
        received.autoPinEdge(.top, to: .bottom, of: sent)
        received.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
    }
}
