@_spi(GliaWidgets) internal import GliaCoreSDK
import Foundation

extension QueuesMonitor {
    struct Environment {
        var getQueues: CoreSdkClient.GetQueues
        var queueUpdatesStream: CoreSdkClient.QueueUpdatesStream
        var logger: CoreSdkClient.Logger
    }
}
