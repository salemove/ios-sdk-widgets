import Foundation
@testable import GliaWidgets

extension Interactor.Environment {
    static let failing = Self(
        coreSdk: .failing,
        queuesMonitor: .failing,
        gcd: .failing,
        log: .failing
    )
}
