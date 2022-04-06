extension GCD {
    static let mock = Self(
        mainQueue: .mock,
        globalQueue: .mock
    )
}

extension GCD.DispatchQueue {
    static let mock = Self(
        async: { callback in
            callback()
        }
    )
}
