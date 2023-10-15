@testable import GliaWidgets

extension CoreSDKConfigurator {
    static let failing = Self.init(
        configureWithInteractor: { _ in
            fail("\(Self.self).configureWithInteractor")
        },
        configureWithConfiguration: { _, _ in
            fail("\(Self.self).configureWithConfiguration")
        }
    )
}
