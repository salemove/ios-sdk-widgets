@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

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
        uiApplication: .failing,
        uiScreen: .failing,
        log: .failing,
        uiDevice: .failing,
        combineScheduler: .mock
    )
}
