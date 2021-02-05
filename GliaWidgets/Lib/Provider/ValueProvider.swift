public class ValueProvider<T: Any> {
    public typealias Update = (_ new: T, _ old: T) -> Void

    public var value: T {
        get { aValue }
        set { set(newValue) }
    }

    private var aValue: T
    private var observers = [() -> (AnyObject?, Update)]()

    public init(with object: T) {
        self.aValue = object
    }

    public func addObserver(_ observer: AnyObject, update: @escaping Update) {
        guard !observers.contains(where: { $0().0 === observer }) else { return }
        observers.append({ [weak observer] in (observer, update) })
    }

    public func removeObserver(_ observer: AnyObject) {
        observers.removeAll(where: { $0().0 === observer })
    }

    private func set(_ new: T) {
        let old = aValue
        aValue = new

        observers.compactMap({ $0() }).filter({ $0.0 != nil }).forEach({
            let update = $0.1
            DispatchQueue.main.async {
                update(new, old)
            }
        })
    }
}
