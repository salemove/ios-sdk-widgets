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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addSubview(operatorView)
            operatorView.autoPinEdge(.top, to: .bottom, of: self.header, withOffset: 20)
            operatorView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
            operatorView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
            operatorView.autoAlignAxis(toSuperviewAxis: .vertical)
            operatorView.setState(.enqueued, animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            operatorView.setState(.connecting(name: "Kate"), animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            operatorView.setState(.connected(name: "Kate"), animated: true)
        }

        let sent = SentChatMessageView(with: self.style.sentMessage)
        sent.appendContent(.text("Hi, I need help and guidance with moving money from one account to another"), animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.addSubview(sent)
            sent.autoPinEdge(toSuperviewEdge: .right)
            sent.autoPinEdge(.top, to: .bottom, of: operatorView, withOffset: 20)
            sent.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        }

        let received = ReceivedChatMessageView(with: self.style.receivedMessage)
        received.appendContent(.text("Hi, Roger! I’d be glad to help you out. Could you specify the accounts that you want to use."), animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 13) {
            self.addSubview(received)
            received.autoPinEdge(toSuperviewEdge: .left)
            received.autoPinEdge(.top, to: .bottom, of: sent)
            received.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        }
    }
}
