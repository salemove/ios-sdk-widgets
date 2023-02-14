import Foundation

extension CallVisualizer.VideoCallCoodinator {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
        var screenShareHandler: ScreenShareHandler
    }
}
