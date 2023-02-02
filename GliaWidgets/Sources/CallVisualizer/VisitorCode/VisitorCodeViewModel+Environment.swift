import Foundation

extension CallVisualizer.VisitorCodeViewModel {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
    }
}
