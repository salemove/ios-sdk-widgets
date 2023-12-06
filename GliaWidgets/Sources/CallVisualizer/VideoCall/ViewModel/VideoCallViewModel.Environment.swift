import Foundation

extension CallVisualizer.VideoCallViewModel {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var notificationCenter: FoundationBased.NotificationCenter
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
        var screenShareHandler: ScreenShareHandler
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
    }
}
