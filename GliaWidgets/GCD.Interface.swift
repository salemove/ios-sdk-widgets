import Dispatch

struct GCD {
    var mainQueue: MainQueue
    var globalQueue: DispatchQueue
}

extension GCD {
    struct DispatchQueue {
        var async: (@escaping () -> Void) -> Void
        var asyncAfterDeadline: (DispatchTime, @escaping () -> Void) -> Void
    }

    struct MainQueue {
        var async: (@escaping () -> Void) -> Void
        var asyncIfNeeded: (@escaping () -> Void) -> Void
        var asyncAfterDeadline: (DispatchTime, @escaping () -> Void) -> Void
    }
}
