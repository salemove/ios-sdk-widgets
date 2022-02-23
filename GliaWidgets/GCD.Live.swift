import Dispatch

extension GCD {
    static let live = Self.init(
        mainQueue: .init(
            async: { callback in
                Dispatch.DispatchQueue.main.async {
                    callback()
                }
            }
        ),
        globalQueue: .init(
            async: { callback in
                Dispatch.DispatchQueue.global().async {
                    callback()
                }
            }
        )
    )
}
