@testable import GliaWidgets

extension GCD {
    static let failing = Self(
        mainQueue: .init(
            async: { _ in fail("\(Self.self).mainQueue.async") },
            asyncAfterDeadline: { _, _ in fail("\(Self.self).mainQueue.asyncAfter") }
        ),
        globalQueue: .init(
            async: { _ in fail("\(Self.self).globalQueue.async") },
            asyncAfterDeadline: { _, _ in fail("\(Self.self).globalQueue.asyncAfter") }
        )
    )
}

extension GCD.DispatchQueue {
    static let failing = Self(
        async: { _ in
            fail("\(Self.self).async")
        },
        asyncAfterDeadline: { _, _ in
            fail("\(Self.self).asyncAfter")
        }
    )
}
