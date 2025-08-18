import Foundation
#if DEBUG
extension QueuesMonitor.Environment {
    static let mock: Self = .init(
        getQueues: { [.mock()] },
        subscribeForQueuesUpdates: { _, _ in UUID().uuidString },
        unsubscribeFromUpdates: { _, _ in },
        logger: .mock
    )
}
#endif
