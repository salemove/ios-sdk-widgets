@testable import GliaWidgets

extension GliaPresenter.Environment {
    static let failing = Self(
        appWindowsProvider: .failing,
        log: .failing,
        dismissManager: .failing
    )
}

extension GliaPresenter.DismissManager {
    static let failing = Self.init { _, _, _ in
        fail("\(Self.self).dismissManager")
    }
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
