import Foundation

extension QueuesMonitor {
    struct Environment {
        var listQueues: CoreSdkClient.ListQueues
        var subscribeForQueuesUpdates: CoreSdkClient.SubscribeForQueuesUpdates
        var unsubscribeFromUpdates: CoreSdkClient.UnsubscribeFromUpdates
        var logger: CoreSdkClient.Logger
    }
}
