import Combine
import Foundation

/// A Combine scheduler that runs work only when a test calls `advance(by:)`.
/// Use it to test time-based operators such as `timeout` or `delay` without waiting.
/// Wrap it in `CoreSdkClient.AnyScheduler` to pass it through an environment.
final class TestScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    private struct Work {
        let id: Int
        let date: SchedulerTimeType
        let interval: SchedulerTimeType.Stride?
        let action: () -> Void
    }

    private(set) var now = SchedulerTimeType(.now())
    let minimumTolerance: SchedulerTimeType.Stride = .zero
    private var scheduled: [Work] = []
    private var lastId = 0

    /// Moves time forward by `stride` and runs all work that became due, earliest first.
    /// Without an argument it runs only the work that is due now.
    func advance(by stride: SchedulerTimeType.Stride = .zero) {
        let deadline = now.advanced(by: stride)
        while let next = scheduled
            .filter({ $0.date <= deadline })
            .min(by: { ($0.date, $0.id) < ($1.date, $1.id) }) {
            scheduled.removeAll { $0.id == next.id }
            now = max(now, next.date)
            // Repeating work is queued again before it runs, so the work can cancel itself.
            if let interval = next.interval {
                add(id: next.id, date: next.date.advanced(by: interval), interval: interval, next.action)
            }
            next.action()
        }
        now = deadline
    }

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        add(date: now, action)
    }

    func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        add(date: date, action)
    }

    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> any Cancellable {
        let id = add(date: date, interval: interval, action)
        return AnyCancellable { [weak self] in
            self?.scheduled.removeAll { $0.id == id }
        }
    }

    @discardableResult
    private func add(
        id: Int? = nil,
        date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride? = nil,
        _ action: @escaping () -> Void
    ) -> Int {
        lastId += 1
        let id = id ?? lastId
        scheduled.append(Work(id: id, date: date, interval: interval, action: action))
        return id
    }
}
