#if DEBUG
import Foundation

extension Interactor {
    static func mock(
        // swiftlint:disable force_try
        configuration: CoreSdkClient.Salemove.Configuration = try! .mock(),
        // swiftlint:enable force_try
        queueID: String = UUID.mock.uuidString,
        visitorContext: CoreSdkClient.VisitorContext? = .mock,
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
