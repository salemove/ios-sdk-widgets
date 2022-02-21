#if DEBUG
extension ChatViewModel {
    static func mock(environment: ChatViewModel.Environment = .mock) -> ChatViewModel {
        ChatViewModel(
            interactor: Interactor(
                with: .mock(),
                queueID: "mockQueueId",
                visitorContext: .mock,
                environment: .mock
            ),
            alertConfiguration: .mock(),
            screenShareHandler: ScreenShareHandler(),
            call: .init(with: .init(.audio, environment: .mock)),
            unreadMessages: .init(with: .zero),
            showsCallBubble: false,
            isWindowVisible: .init(with: true),
            startAction: .startEngagement,
            environment: environment
        )
    }
}
#endif
