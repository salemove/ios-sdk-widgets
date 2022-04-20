@testable import GliaWidgets

extension GCD {
    static let failing = Self(
        mainQueue: .init(
            async: { _ in fail("\(Self.self).mainQueue.async") },
            asyncIfNeeded: { _ in fail("\(Self.self).mainQueue.asyncIfNeeded") }
        ),
        globalQueue: .init(async: { _ in fail("\(Self.self).globalQueue.async") })
    )
}

extension GCD.DispatchQueue {
    static let failing = Self(
        async: { _ in
            fail("\(Self.self).async")
        }
    )
}
