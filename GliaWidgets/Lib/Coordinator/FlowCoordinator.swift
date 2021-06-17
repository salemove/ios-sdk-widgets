protocol FlowCoordinator: AnyObject {
    associatedtype ViewController
    associatedtype DelegateEvent

    func start() -> ViewController
    var delegate: ((DelegateEvent) -> Void)? { get set }
}
