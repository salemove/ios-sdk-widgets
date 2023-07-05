@testable import GliaWidgets

extension ChatMessageEntryView {
    static func mock(
        with style: ChatMessageEntryStyle = Theme().chatStyle.messageEntry,
        environment: Environment = .init(
            gcd: .mock,
            uiApplication: .mock,
            uiScreen: .mock
        )
    ) -> ChatMessageEntryView {
        ChatMessageEntryView(
            with: style,
            environment: environment
        )
    }
}
