@testable import GliaWidgets

extension TaskSleep {
    static let failing = Self(
        taskSleep: { _ in
            fail("\(Self.self).taskSleep")
        }
    )
}
