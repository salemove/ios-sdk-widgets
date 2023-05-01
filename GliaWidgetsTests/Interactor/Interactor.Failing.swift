import Foundation
@testable import GliaWidgets

extension Interactor {
    static let failing = Interactor(
        configuration: .mock(),
        queueID: "mocked-id",
        environment: .failing
    )
}
