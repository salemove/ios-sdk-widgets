import Foundation

protocol FlowCoordinator: AnyObject {
    associatedtype ViewController
    associatedtype DelegateEvent

    var delegate: ((DelegateEvent) -> Void)? { get set }

    func start() -> ViewController
}
