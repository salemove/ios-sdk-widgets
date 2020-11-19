final class ChatViewModel: ViewModel {
    enum Event {}

    enum Action {}

    enum DelegateEvent {}

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    init() {}

    public func event(_ event: Event) {}
}
