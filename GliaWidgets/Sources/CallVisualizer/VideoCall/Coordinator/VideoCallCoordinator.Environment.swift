import Foundation

extension CallVisualizer.VideoCallCoordinator {
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
        var date: () -> Date
        var engagedOperator: () -> CoreSdkClient.Operator?
        var proximityManager: ProximityManager
        var log: CoreSdkClient.Logger
        var cameraDeviceManager: CoreSdkClient.GetCameraDeviceManageable
        var flipCameraButtonStyle: FlipCameraButtonStyle
    }
}

extension CallVisualizer.VideoCallCoordinator.Environment {
    static func create(with environment: CallVisualizer.Coordinator.Environment) -> Self {
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
            date: environment.date,
            engagedOperator: environment.engagedOperator,
            proximityManager: environment.proximityManager,
            log: environment.log,
            cameraDeviceManager: environment.cameraDeviceManager,
            flipCameraButtonStyle: environment.viewFactory.theme.call.flipCameraButtonStyle
        )
    }
}
