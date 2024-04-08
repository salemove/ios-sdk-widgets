import Foundation

struct TaskSleep {
    var taskSleep: (_ delay: UInt64) async throws -> Void

    func callAsFunction(_ delay: UInt64) async throws {
        try await taskSleep(delay)
    }
}

extension TaskSleep {
    static let live = Self(
        taskSleep: { timeToWait in
            try await Task.sleep(nanoseconds: timeToWait)
        }
    )
}

#if DEBUG
extension TaskSleep {
    static let mock = Self(taskSleep: { _ in })
}
#endif
