final class ChatViewModel: ViewModel {
    enum Event {
        case backTapped
        case closeTapped
    }

    enum Action {}

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    init() {}

    public func event(_ event: Event) {
        switch event {
        case .backTapped:
            delegate?(.finished)
        case .closeTapped:
            delegate?(.finished)
        }
    }
}
