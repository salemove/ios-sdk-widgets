import Foundation

extension CallVisualizer.Coordinator {
    struct Environment {
        var viewFactory: ViewFactory
        var presenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
        var screenShareHandler: ScreenShareHandler
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
    }
}
