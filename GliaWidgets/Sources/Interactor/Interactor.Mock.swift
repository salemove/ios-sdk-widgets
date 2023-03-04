#if DEBUG
import Foundation

extension Interactor {
    static func mock(
        configuration: Configuration = .mock(),
        queueID: String = UUID.mock.uuidString,
        environment: Environment = .mock
    ) -> Interactor {
        .init(
            configuration: configuration,
            queueID: queueID,
            environment: environment
        )
    }
}
#endif
