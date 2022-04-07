#if DEBUG
extension ChatViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        alertConfiguration: AlertConfiguration = .mock(),
        screenShareHandler: ScreenShareHandler = .init(),
        call: ObservableValue<Call?> = .init(with: .init(.audio, environment: .mock)),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        showsCallBubble: Bool = false,
        isWindowVisible: ObservableValue<Bool> = .init(with: true),
        startAction: StartAction = .startEngagement,
        environment: Environment = .mock
    ) -> ChatViewModel {
        ChatViewModel(
            interactor: interactor,
            alertConfiguration: alertConfiguration,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            environment: environment
        )
    }
}
#endif
