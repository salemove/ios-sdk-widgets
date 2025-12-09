import Foundation
import Combine
import GliaCoreSDK

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
        var interactorPublisher: AnyPublisher<Interactor?, Never>
        var callVisualizerPresenter: CallVisualizer.Presenter
        var bundleManaging: BundleManaging
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
        var coreSdk: CoreSdkClient
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var alertManager: AlertManager
        var combineScheduler: CoreSdkClient.AnyCombineScheduler
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension CallVisualizer.Environment {
    static func create(
        with environment: Glia.Environment,
        interactorPublisher: AnyPublisher<Interactor?, Never>,
        engagedOperator: @escaping () -> CoreSdkClient.Operator?,
        theme: Theme,
        assetBuilder: @escaping () -> RemoteConfiguration.AssetsBuilder,
        onEvent: ((GliaEvent) -> Void)?,
        loggerPhase: Glia.LoggerPhase,
        alertManager: AlertManager
    ) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            timerProviding: environment.timerProviding,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            uiDevice: environment.uiDevice,
            notificationCenter: environment.notificationCenter,
            requestVisitorCode: environment.coreSdk.requestVisitorCode,
            interactorPublisher: interactorPublisher,
            callVisualizerPresenter: environment.callVisualizerPresenter,
            bundleManaging: environment.bundleManaging,
            audioSession: environment.audioSession,
            date: environment.date,
            engagedOperator: engagedOperator,
            theme: theme,
            assetsBuilder: assetBuilder,
            getCurrentEngagement: environment.coreSdk.getCurrentEngagement,
            eventHandler: onEvent,
            orientationManager: environment.orientationManager,
            proximityManager: environment.proximityManager,
            log: loggerPhase.logger,
            fetchSiteConfigurations: environment.coreSdk.fetchSiteConfigurations,
            coreSdk: environment.coreSdk,
            cameraDeviceManager: environment.cameraDeviceManager,
            alertManager: alertManager,
            combineScheduler: environment.combineScheduler
        )
    }
}
