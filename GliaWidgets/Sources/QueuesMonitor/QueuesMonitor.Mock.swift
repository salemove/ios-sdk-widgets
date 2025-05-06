#if DEBUG
extension QueuesMonitor {
    static func mock(
        getQueues: CoreSdkClient.GetQueues? = nil,
        subscribeForQueuesUpdates: CoreSdkClient.SubscribeForQueuesUpdates? = nil,
        unsubscribeFromUpdates: CoreSdkClient.UnsubscribeFromUpdates? = nil
    ) -> Self {
        Self(
            environment: .init(
                getQueues: getQueues ?? QueuesMonitor.Environment.mock.getQueues,
                subscribeForQueuesUpdates: subscribeForQueuesUpdates ?? QueuesMonitor.Environment.mock.subscribeForQueuesUpdates,
                unsubscribeFromUpdates: unsubscribeFromUpdates ?? QueuesMonitor.Environment.mock.unsubscribeFromUpdates,
                logger: .mock
            )
        )
    }
}
#endif
