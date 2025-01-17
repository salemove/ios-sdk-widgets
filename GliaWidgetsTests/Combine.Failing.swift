@testable import GliaWidgets

extension CombineBased.CombineScheduler {
    static let failing = Self(
        main: {
            fail("\(Self.self).main")
            return mock.main()
        },
        global: {
            fail("\(Self.self).global")
            return mock.global()
        }
    )
}
