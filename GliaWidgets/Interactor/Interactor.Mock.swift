#if DEBUG
import Foundation

extension Interactor {
    static func mock(
        configuration: CoreSdkClient.Salemove.Configuration = .mock(),
        queueID: String = UUID.mock.uuidString,
        visitorContext: CoreSdkClient.VisitorContext = .mock,
        environment: Environment = .mock
    ) -> Interactor {
        .init(
            with: configuration,
            queueID: queueID,
            visitorContext: visitorContext,
            environment: environment
        )
    }
}
#endif
