#if DEBUG
extension ChatViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        alertConfiguration: AlertConfiguration = .mock(),
        screenShareHandler: ScreenShareHandler = .mock,
        call: ObservableValue<Call?> = .init(with: .init(.audio, environment: .mock)),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        showsCallBubble: Bool = false,
        isCustomCardSupported: Bool = true,
        isWindowVisible: ObservableValue<Bool> = .init(with: true),
        startAction: StartAction = .startEngagement,
        deliveredStatusText: String = "Delivered",
        failedToDeliverStatusText: String = "Failed",
        chatType: ChatViewModel.ChatType = .nonAuthenticated,
        environment: Environment = .mock,
        maximumUploads: () -> Int = { 2 }
    ) -> ChatViewModel {
        ChatViewModel(
            interactor: interactor,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isCustomCardSupported: isCustomCardSupported,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            deliveredStatusText: deliveredStatusText,
            failedToDeliverStatusText: failedToDeliverStatusText,
            chatType: chatType,
            environment: environment,
            maximumUploads: maximumUploads
        )
    }
}
#endif
