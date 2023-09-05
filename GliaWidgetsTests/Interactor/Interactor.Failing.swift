import Foundation
@testable import GliaWidgets

extension Interactor {
    static let failing = Interactor(
        configuration: .mock(),
        queueIds: ["mocked-id"],
        environment: .failing
    )
}
