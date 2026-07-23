import Foundation
#if DEBUG
extension QueuesMonitor.Environment {
    static let mock: Self = .init(
        getQueues: { [.mock()] },
        subscribeForQueuesUpdates: { _ in AsyncThrowingStream { $0.finish() } },
        logger: .mock
    )
}
#endif
