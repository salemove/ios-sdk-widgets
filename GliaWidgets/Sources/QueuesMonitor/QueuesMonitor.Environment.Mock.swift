#if DEBUG
extension QueuesMonitor.Environment {
    static let mock: Self = .init(
        listQueues: { _ in },
        subscribeForQueuesUpdates: { _, _ in UUID().uuidString },
        unsubscribeFromUpdates: { _, _ in }
    )
}
#endif
