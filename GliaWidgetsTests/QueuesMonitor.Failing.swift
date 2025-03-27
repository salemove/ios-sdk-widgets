@testable import GliaWidgets

extension QueuesMonitor {
    static let failing = QueuesMonitor(
        environment: .init(
            getQueues: CoreSdkClient.failing.getQueues,
            subscribeForQueuesUpdates: CoreSdkClient.failing.subscribeForQueuesUpdates,
            unsubscribeFromUpdates: CoreSdkClient.failing.unsubscribeFromUpdates,
            logger: .failing
        )
    )
}
