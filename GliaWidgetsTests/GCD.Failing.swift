@testable import GliaWidgets

extension GCD {
    static let failing = Self(
        mainQueue: .init(async: { _ in fail("\(Self.self).mainQueue.async") }),
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
