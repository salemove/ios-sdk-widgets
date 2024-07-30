import Foundation
@testable import GliaWidgets

extension Interactor {
    static var failing: Interactor {
        Interactor(
            visitorContext: nil,
            environment: .failing
        )
    }
}
