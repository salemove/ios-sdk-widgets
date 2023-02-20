import Foundation

extension CallVisualizer.Coordinator {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiApplication: UIKitBased.UIApplication
        var viewFactory: ViewFactory
        var presenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
        var screenShareHandler: ScreenShareHandler
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
        var audioSession: Glia.Environment.AudioSession
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
    }
}
