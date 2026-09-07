@_spi(GliaWidgets) internal import GliaCoreSDK
import Foundation

extension QueuesMonitor {
    struct Environment {
        var getQueues: CoreSdkClient.GetQueues
        var subscribeForQueuesUpdates: CoreSdkClient.SubscribeForQueuesUpdates
        var logger: CoreSdkClient.Logger
    }
}
