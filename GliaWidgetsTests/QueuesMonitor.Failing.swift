@testable import GliaWidgets

extension QueuesMonitor {
    static let failing = QueuesMonitor(
        environment: .init(
            listQueues: CoreSdkClient.failing.listQueues,
            subscribeForQueuesUpdates: CoreSdkClient.failing.subscribeForQueuesUpdates,
            unsubscribeFromUpdates: CoreSdkClient.failing.unsubscribeFromUpdates
        )
    )
}
