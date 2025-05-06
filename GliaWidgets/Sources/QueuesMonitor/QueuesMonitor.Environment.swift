import Foundation

extension QueuesMonitor {
    struct Environment {
        var getQueues: CoreSdkClient.GetQueues
        var subscribeForQueuesUpdates: CoreSdkClient.SubscribeForQueuesUpdates
        var unsubscribeFromUpdates: CoreSdkClient.UnsubscribeFromUpdates
        var logger: CoreSdkClient.Logger
    }
}
