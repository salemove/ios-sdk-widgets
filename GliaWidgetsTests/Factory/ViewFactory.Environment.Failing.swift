@testable import GliaWidgets

extension ViewFactory.Environment {
    static let failing = Self(
        data: .failing,
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
        },
        gcd: .failing,
        imageViewCache: .failing,
        timerProviding: .failing,
        uiApplication: .failing
    )
}
