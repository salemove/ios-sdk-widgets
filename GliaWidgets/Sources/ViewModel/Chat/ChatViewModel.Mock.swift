#if DEBUG
extension ChatViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        alertConfiguration: AlertConfiguration = .mock(),
        call: ObservableValue<Call?> = .init(with: .init(.audio, environment: .mock)),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        showsCallBubble: Bool = false,
        isCustomCardSupported: Bool = true,
        isWindowVisible: ObservableValue<Bool> = .init(with: true),
        startAction: StartAction = .startEngagement,
        deliveredStatusText: String = "Delivered",
        failedToDeliverStatusText: String = "Failed",
        chatType: ChatViewModel.ChatType = .nonAuthenticated,
        replaceExistingEnqueueing: Bool = false,
        environment: Environment = .mock,
        maximumUploads: () -> Int = { 2 }
    ) -> ChatViewModel {
        ChatViewModel(
            interactor: interactor,
            call: call,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            isCustomCardSupported: isCustomCardSupported,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            deliveredStatusText: deliveredStatusText,
            failedToDeliverStatusText: failedToDeliverStatusText,
            chatType: chatType,
            replaceExistingEnqueueing: replaceExistingEnqueueing,
            environment: environment,
            maximumUploads: maximumUploads
        )
    }
}
#endif
