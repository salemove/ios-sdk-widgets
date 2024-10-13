#if DEBUG
import Foundation

extension QueuesMonitor {
    static let mock = QueuesMonitor(
        environment: .init(
            listQueues: { _ in },
            subscribeForQueuesUpdates: { _, _ in UUID().uuidString },
            unsubscribeFromUpdates: { _, _ in }
        )
    )
}
#endif
