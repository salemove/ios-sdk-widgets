#if DEBUG
extension CallViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        alertConfiguration: AlertConfiguration = .mock(),
        screenShareHandler: ScreenShareHandler = .init(),
        call: Call = .init(.audio, environment: .mock),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        startWith: StartAction = .engagement(mediaType: .audio),
        environment: CallViewModel.Environment = .mock
    ) -> CallViewModel {
        .init(
            interactor: interactor,
            alertConfiguration: alertConfiguration,
            screenShareHandler: screenShareHandler,
            environment: environment,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startWith
        )
    }
}

#endif
