@testable import GliaWidgets

extension GCD {
    static let failing = Self(
        mainQueue: .failing,
        globalQueue: .failing
    )
}

extension GCD.DispatchQueue {
    static let failing = Self(
        async: { _ in
            fail("\(Self.self).async")
        }
    )
}
