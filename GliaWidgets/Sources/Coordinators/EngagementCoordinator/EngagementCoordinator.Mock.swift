#if DEBUG
extension EngagementCoordinator {
    static func mock(
        interactor: Interactor = .mock(),
        viewFactory: ViewFactory = .mock(),
        sceneProvider: SceneProvider? = nil,
        engagementKind: EngagementKind = .audioCall,
        screenShareHandler: ScreenShareHandler = .mock,
        features: Features = .all,
        environment: Environment = .mock
    ) -> EngagementCoordinator {
        EngagementCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            screenShareHandler: screenShareHandler,
            features: features,
            environment: environment
        )
    }
}
#endif
