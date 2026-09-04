#if DEBUG
extension QueuesMonitor {
    static func mock(
        getQueues: CoreSdkClient.GetQueues? = nil,
        subscribeForQueuesUpdates: CoreSdkClient.SubscribeForQueuesUpdates? = nil
    ) -> Self {
        Self(
            environment: .init(
                getQueues: getQueues ?? QueuesMonitor.Environment.mock.getQueues,
                subscribeForQueuesUpdates: subscribeForQueuesUpdates ?? QueuesMonitor.Environment.mock.subscribeForQueuesUpdates,
                logger: .mock
            )
        )
    }
}
#endif
