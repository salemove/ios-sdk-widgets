import Foundation
@testable import GliaWidgets

extension OperatorRequestHandlerService {
    static let failing: OperatorRequestHandlerService = .init(
        environment: .init(
            uiApplication: .failing,
            log: .failing
        ),
        viewFactory: .mock()
    )
}

