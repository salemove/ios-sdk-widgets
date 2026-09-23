@testable import GliaWidgets

extension QueuesMonitor {
    static let failing = QueuesMonitor(
        environment: .init(
            getQueues: CoreSdkClient.failing.getQueues,
            queueUpdatesStream: CoreSdkClient.failing.queueUpdatesStream,
            logger: .failing
        )
    )
}
