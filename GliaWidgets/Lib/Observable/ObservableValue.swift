import Foundation

class ObservableValue<T: Any> {
    typealias Update = (_ new: T, _ old: T) -> Void

    public var value: T {
        get { aValue }
        set { set(newValue) }
    }

    private var aValue: T
    private var observers = [() -> (AnyObject?, Update)]()

    init(with object: T) {
        self.aValue = object
    }

    func addObserver(_ observer: AnyObject, update: @escaping Update) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append { [weak observer] in (observer, update) }
    }

    func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
    }

    private func set(_ new: T) {
        let old = aValue
        aValue = new

        observers
            .compactMap { $0() }
            .filter { $0.0 != nil }
            .forEach {
                let update = $0.1
                // Avoid unnecessary thread hop (causing code to run asynchronously),
                // if current thread is already main.
                // Since initial assumption of this class
                // was that `update` closure
                // must always run on main queue, I added
                // this check. But we must use some
                // battle-tested solutuion like ReactiveSwift or Combine.
                // That will allow us to use proper schedulers for UI, unit tests etc.
                if Thread.isMainThread {
                    update(new, old)
                } else {
                    DispatchQueue.main.async {
                        update(new, old)
                    }
                }
            }
    }
}
