import Foundation

extension ViewFactory {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var log: CoreSdkClient.Logger
        var uiDevice: UIKitBased.UIDevice
        var combineScheduler: CoreSdkClient.AnyCombineScheduler
    }
}

extension ViewFactory.Environment {
    static func create(
        with environment: Glia.Environment,
        loggerPhase: Glia.LoggerPhase
    ) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            timerProviding: environment.timerProviding,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            log: loggerPhase.logger,
            uiDevice: environment.uiDevice,
            combineScheduler: environment.combineScheduler
        )
    }

    static func create(with environment: CallVisualizer.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            timerProviding: environment.timerProviding,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            log: environment.log,
            uiDevice: environment.uiDevice,
            combineScheduler: environment.combineScheduler
        )
    }
}
