import Foundation
@testable import GliaWidgets

extension Interactor {
    static var failing: Interactor {
        Interactor(
            visitorContext: nil,
            queueIds: ["mocked-id"],
            environment: .failing
        )
    }
}
