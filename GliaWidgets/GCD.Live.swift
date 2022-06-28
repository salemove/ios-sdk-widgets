import Dispatch

extension GCD {
    static let live = Self(
        mainQueue: .init(
            async: { callback in
                Dispatch.DispatchQueue.main.async {
                  callback()
                }
            },
            asyncIfNeeded: { callback in
                if Thread.isMainThread {
                    callback()
                } else {
                    Dispatch.DispatchQueue.main.async {
                        callback()
                    }
                }
            },
            asyncAfterDeadline: { deadline, callback in
                Dispatch.DispatchQueue.main.asyncAfter(deadline: deadline) {
                    callback()
                }
            }
        ),
        globalQueue: .init(
            async: { callback in
                Dispatch.DispatchQueue.global().async {
                    callback()
                }
            },
            asyncAfterDeadline: { deadline, callback in
                Dispatch.DispatchQueue.global().asyncAfter(deadline: deadline) {
                    callback()
                }
            }
        )
    )
}
