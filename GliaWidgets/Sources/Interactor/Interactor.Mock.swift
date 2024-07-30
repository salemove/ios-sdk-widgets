#if DEBUG
import Foundation

extension Interactor {
    static func mock(
        visitorContext: Configuration.VisitorContext? = nil,
        environment: Environment = .mock
    ) -> Interactor {
        .init(
            visitorContext: visitorContext,
            environment: environment
        )
    }
}
#endif
