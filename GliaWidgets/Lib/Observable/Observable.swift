import Foundation

class Observable<T> {
    typealias Observer = (T) -> Void

    private var observers: [Int: Observer] = [:]
    private var iterator = (0...).makeIterator()

    fileprivate let lock = NSRecursiveLock()

    var value: T? {
        fatalError("Must be implemented by subclass")
    }

    fileprivate init() {}

    func observe(_ observer: @escaping Observer) -> Disposable {
        lock.lock()

        defer {
            lock.unlock()
        }

        let id = iterator.next()!
        observers[id] = observer

        return Disposable { [weak self] in
            self?.observers[id] = nil
        }
    }

    func removeAllObservers() {
        observers.removeAll()
    }

    fileprivate func notifyObservers(with value: T) {
        observers.values.forEach { observer in
            observer(value)
        }
    }
}

class PublishSubject<T>: Observable<T> {
    override var value: T? {
        _value
    }

    private var _value: T?

    override init() {
        super.init()
    }

    public func send(_ value: T) {
        _value = value

        notifyObservers(with: value)
    }
}

class CurrentValueSubject<T>: Observable<T> {
    override var value: T {
        get { _value }
        set { _value = newValue }
    }

    private var _value: T

    init(_ value: T) {
        _value = value

        super.init()
    }

    public func send(_ value: T) {
        _value = value

        notifyObservers(with: value)
    }

    override func observe(_ observer: @escaping Observer) -> Disposable {
        let disposable = super.observe(observer)

        observer(_value)

        return disposable
    }
}
