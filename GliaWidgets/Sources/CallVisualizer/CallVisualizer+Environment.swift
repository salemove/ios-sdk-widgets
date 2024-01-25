import Foundation

extension CallVisualizer {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var uiDevice: UIKitBased.UIDevice
        var notificationCenter: FoundationBased.NotificationCenter
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
        var interactorProviding: () -> Interactor?
        var callVisualizerPresenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
        var screenShareHandler: ScreenShareHandler
        var audioSession: Glia.Environment.AudioSession
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
        var theme: Theme
        var assetsBuilder: () -> RemoteConfiguration.AssetsBuilder
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var eventHandler: ((GliaEvent) -> Void)?
        var orientationManager: OrientationManager
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var snackBar: SnackBar
        var localizationProviding: Localization2.Providing
    }
}
