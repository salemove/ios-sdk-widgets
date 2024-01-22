extension CallVisualizer.VisitorCodeCoordinator {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var requestVisitorCode: CoreSdkClient.RequestVisitorCode
        var localizationProviding: Localization2.Providing
    }
}
