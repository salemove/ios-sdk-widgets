import Foundation
#if DEBUG
extension QueuesMonitor.Environment {
    static let mock: Self = .init(
        getQueues: { _ in },
        subscribeForQueuesUpdates: { _, _ in UUID().uuidString },
        unsubscribeFromUpdates: { _, _ in },
        logger: .mock
    )
}
#endif
