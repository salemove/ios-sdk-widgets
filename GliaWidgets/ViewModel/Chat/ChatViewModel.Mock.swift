#if DEBUG
extension ChatViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        alertConfiguration: AlertConfiguration = .mock(),
        screenShareHandler: ScreenShareHandler = .init(),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        isWindowVisible: ObservableValue<Bool> = .init(with: true),
        showsCallBubble: Bool = false,
        startAction: StartAction = .startEngagement,
        environment: Environment = .mock
    ) -> ChatViewModel {
        ChatViewModel(
            interactor: interactor,
            alertConfiguration: alertConfiguration,
            screenShareHandler: screenShareHandler,
            unreadMessages: unreadMessages,
            isWindowVisible: isWindowVisible,
            showsCallBubble: showsCallBubble,
            startAction: startAction,
            environment: environment
        )
    }
}
#endif
