import Dispatch

struct GCD {
    var mainQueue: DispatchQueue
    var globalQueue: DispatchQueue
}

extension GCD {
    struct DispatchQueue {
        var async: (@escaping () -> Void) -> Void
        var asyncAfterDeadline: (DispatchTime, @escaping () -> Void) -> Void
    }
}
