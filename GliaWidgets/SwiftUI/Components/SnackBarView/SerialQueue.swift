import Foundation

/// The queue with serial strategy. Not thread-safe.
/// Allows to synchronise operations and build serial
/// queue to achive use case when SDK have to do some
/// operations only after the previous one is done.
final class SerialQueue {
    /// Adds operation to end of  serial queue
    func addOperation(_ op: Operation) {
        let needToRun = queue.isEmpty
        queue.append(op)
        if needToRun {
            run()
        }
    }

    // MARK: - Private

    private(set) var queue = [Operation]()

    private func run() {
        guard let operation = queue.first else { return }

        operation.didFinish = { [weak self] in
            self?.queue.removeFirst()
            self?.run()
        }
        operation.run()
    }
}

extension SerialQueue {
    /// Defines operation for using in SerialQueue.
    ///
    ///
    /// Example of implementation that waits for
    /// `seconds` and executes `done` for the operation:
    /// ```swift
    /// extension SerialQueue.Operation {
    ///     static func timeout(seconds: Int) -> Self {
    ///         .init(
    ///             action: { done in
    ///                 DispatchQueue.main.asyncAfter(
    ///                     deadline: .now() + .seconds(seconds),
    ///                     execute: done
    ///                 )
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    final class Operation {
        var didFinish: (() -> Void)?
        let action: (_ done: @escaping() -> Void) -> Void

        init(action: @escaping (_ done: @escaping () -> Void) -> Void) {
            self.action = action
        }

        func run() {
            action(didFinish ?? {})
        }
    }
}
