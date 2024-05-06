#if DEBUG
import Foundation

extension Interactor {
    static func mock(
        visitorContext: Configuration.VisitorContext? = nil,
        queueId: String = UUID.mock.uuidString,
        environment: Environment = .mock
    ) -> Interactor {
        .init(
            visitorContext: visitorContext,
            queueInformation: [QueueInformation(kind: .chat, queueIds: [queueId])],
            environment: environment
        )
    }
}
#endif
