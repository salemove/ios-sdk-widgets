public protocol ViewModel {
    associatedtype Event
    associatedtype Action
    associatedtype DelegateEvent

    func event(_ event: Event)
    var action: ((Action) -> Void)? { get set }
    var delegate: ((DelegateEvent) -> Void)? { get set }
}
