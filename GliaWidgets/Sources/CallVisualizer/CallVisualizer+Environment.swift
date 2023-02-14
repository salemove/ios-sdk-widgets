import Foundation

extension CallVisualizer {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var callVisualizerImageViewCache: VideoCallViewModel.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
        var interactorProviding: () -> Interactor?
        var callVisualizerPresenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
        var screenShareHandler: ScreenShareHandler
        var audioSession: Glia.Environment.AudioSession
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
    }
}
