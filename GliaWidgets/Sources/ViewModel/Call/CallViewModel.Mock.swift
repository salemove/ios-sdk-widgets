#if DEBUG
extension CallViewModel {
    static func mock(
        interactor: Interactor = .mock(),
        call: Call = .init(.audio, environment: .mock),
        unreadMessages: ObservableValue<Int> = .init(with: .zero),
        startWith: StartAction = .engagement(mediaType: .audio),
        replaceExistingEnqueueing: Bool = false,
        environment: CallViewModel.Environment = .mock
    ) -> CallViewModel {
        .init(
            interactor: interactor,
            environment: environment,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startWith,
            replaceExistingEnqueueing: replaceExistingEnqueueing,
            aiScreenContextSummary: nil
        )
    }
}

#endif
