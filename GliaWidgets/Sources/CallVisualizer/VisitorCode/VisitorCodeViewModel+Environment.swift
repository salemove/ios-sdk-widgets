import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension CallVisualizer.VisitorCodeViewModel {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension CallVisualizer.VisitorCodeViewModel.Environment {
    static func create(with environment: CallVisualizer.VisitorCodeCoordinator.Environment) -> Self {
        .init(
            timerProviding: environment.timerProviding,
            requestVisitorCode: environment.requestVisitorCode
        )
    }
}
