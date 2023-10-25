import Foundation
@testable import GliaWidgets

extension ProximityManager {
    static let failing = ProximityManager(environment: .failing)
}

extension ProximityManager.Environment {
    static let failing = Self(
        uiApplication: .failing,
        uiDevice: .failing
    )
}
