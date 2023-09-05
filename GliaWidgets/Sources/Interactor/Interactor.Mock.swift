#if DEBUG
import Foundation

extension Interactor {
    static func mock(
        configuration: Configuration = .mock(),
        queueId: String = UUID.mock.uuidString,
        environment: Environment = .mock
    ) -> Interactor {
        .init(
            configuration: configuration,
            queueIds: [queueId],
            environment: environment
        )
    }
}
#endif
