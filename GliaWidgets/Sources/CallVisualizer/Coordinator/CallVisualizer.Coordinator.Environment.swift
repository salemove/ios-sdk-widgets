import Foundation
import Combine

extension CallVisualizer.Coordinator {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var uiDevice: UIKitBased.UIDevice
        var notificationCenter: FoundationBased.NotificationCenter
        var viewFactory: ViewFactory
        var presenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
        var audioSession: Glia.Environment.AudioSession
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
        var eventHandler: (DelegateEvent) -> Void
        var orientationManager: OrientationManager
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var interactorPublisher: AnyPublisher<Interactor?, Never>
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var snackBar: SnackBar
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var alertManager: AlertManager
    }
}

extension CallVisualizer.Coordinator.Environment {
    static func create(
        with environment: CallVisualizer.Environment,
        viewFactory: ViewFactory,
        eventHandler: @escaping (CallVisualizer.Coordinator.DelegateEvent) -> Void
    ) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            uiDevice: environment.uiDevice,
            notificationCenter: environment.notificationCenter,
            viewFactory: viewFactory,
            presenter: environment.callVisualizerPresenter,
            bundleManaging: environment.bundleManaging,
            timerProviding: environment.timerProviding,
            requestVisitorCode: environment.requestVisitorCode,
            audioSession: environment.audioSession,
            date: environment.date,
            engagedOperator: environment.engagedOperator,
            eventHandler: eventHandler,
            orientationManager: environment.orientationManager,
            proximityManager: environment.proximityManager,
            log: environment.log,
            interactorPublisher: environment.interactorPublisher,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            snackBar: environment.snackBar,
            cameraDeviceManager: environment.cameraDeviceManager,
            alertManager: environment.alertManager
        )
    }
}
