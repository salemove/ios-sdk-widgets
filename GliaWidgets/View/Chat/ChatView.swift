final class ChatView: View {
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

        let sent = SentChatMessageView(with: style.sentMessage)
        sent.content = .text("Hi, I need help and guidance with moving money from one account to another")
        let received = ReceivedChatMessageView(with: style.receivedMessage)
        received.content = .text("Hi, Roger! I’d be glad to help you out. Could you specify the accounts that you want to use.")

        addSubview(sent)
        sent.autoPinEdge(toSuperviewEdge: .right)
        sent.autoPinEdge(.top, to: .bottom, of: header, withOffset: 20)
        sent.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)

        addSubview(received)
        received.autoPinEdge(toSuperviewEdge: .left)
        received.autoPinEdge(.top, to: .bottom, of: sent)
        received.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        received.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
    }
}
