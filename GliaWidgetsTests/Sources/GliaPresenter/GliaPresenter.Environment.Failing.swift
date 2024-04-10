@testable import GliaWidgets

extension GliaPresenter.Environment {
    static let failing = Self(
        appWindowsProvider: .failing,
        log: .failing
    )
}

extension GliaPresenter.AppWindowsProvider {
    static let failing = Self.init(
        windows: {
            fail("\(Self.self).windows")
            return [.mock()]
        }
    )
}

extension GliaPresenter.Environment: Transformable {}
extension GliaPresenter.AppWindowsProvider: Transformable {}
