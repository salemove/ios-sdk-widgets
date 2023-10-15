import Foundation
@testable import GliaWidgets

extension Interactor {
    static let failing = Interactor(
        visitorContext: nil,
        queueIds: ["mocked-id"],
        environment: .failing
    )
}
