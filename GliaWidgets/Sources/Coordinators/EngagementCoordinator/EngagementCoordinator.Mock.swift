#if DEBUG
extension EngagementCoordinator {
    static func mock(
        interactor: Interactor = .mock(),
        viewFactory: ViewFactory = .mock(),
        sceneProvider: SceneProvider? = nil,
        engagementLaunching: EngagementCoordinator.EngagementLaunching = .direct(kind: .audioCall),
        features: Features = .all,
        aiScreenContextSummary: AiScreenContext? = nil,
        environment: Environment = .mock
    ) -> EngagementCoordinator {
        EngagementCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementLaunching: engagementLaunching,
            features: features,
            aiScreenContextSummary: aiScreenContextSummary,
            environment: environment
        )
    }
}
#endif
