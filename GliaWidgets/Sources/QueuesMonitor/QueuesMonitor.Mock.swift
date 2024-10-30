#if DEBUG
extension QueuesMonitor {
    static func mock(
        listQueues: CoreSdkClient.ListQueues? = nil,
        subscribeForQueuesUpdates: CoreSdkClient.SubscribeForQueuesUpdates? = nil,
        unsubscribeFromUpdates: CoreSdkClient.UnsubscribeFromUpdates? = nil
    ) -> Self {
        Self(
            environment: .init(
                listQueues: listQueues ?? QueuesMonitor.Environment.mock.listQueues,
                subscribeForQueuesUpdates: subscribeForQueuesUpdates ?? QueuesMonitor.Environment.mock.subscribeForQueuesUpdates,
                unsubscribeFromUpdates: unsubscribeFromUpdates ?? QueuesMonitor.Environment.mock.unsubscribeFromUpdates
            )
        )
    }
}
#endif
