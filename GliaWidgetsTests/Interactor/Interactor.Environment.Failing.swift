@testable import GliaWidgets
extension Interactor.Environment {
    static let failing = Self(
        coreSdk: .failing,
        gcd: .failing
    )
}
