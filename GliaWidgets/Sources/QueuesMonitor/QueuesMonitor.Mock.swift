@_spi(GliaWidgets) internal import GliaCoreSDK
#if DEBUG
extension QueuesMonitor {
    static func mock(
        getQueues: CoreSdkClient.GetQueues? = nil,
        queueUpdatesStream: CoreSdkClient.QueueUpdatesStream? = nil
    ) -> Self {
        Self(
            environment: .init(
                getQueues: getQueues ?? QueuesMonitor.Environment.mock.getQueues,
                queueUpdatesStream: queueUpdatesStream ?? QueuesMonitor.Environment.mock.queueUpdatesStream,
                logger: .mock
            )
        )
    }
}
#endif
