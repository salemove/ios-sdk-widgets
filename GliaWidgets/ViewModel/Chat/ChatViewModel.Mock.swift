#if DEBUG
extension ChatViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        alertConfiguration: AlertConfiguration = .mock(),
        screenShareHandler: ScreenShareHandler = .init(),
        call: ObservableValue<Call?> = .init(with: .init(.audio, environment: .mock)),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        showsCallBubble: Bool = false,
        isCustomCardSupported: Bool = true,
        isWindowVisible: ObservableValue<Bool> = .init(with: true),
        startAction: StartAction = .startEngagement,
        chatStorageState: @escaping () -> ChatStorageState = { .unauthenticated(.mock) },
        environment: Environment = .mock
    ) -> ChatViewModel {
        ChatViewModel(
            interactor: interactor,
            alertConfiguration: alertConfiguration,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isCustomCardSupported: isCustomCardSupported,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            chatStorageState: chatStorageState,
            environment: environment
        )
    }
}
#endif
