#if DEBUG
extension RootCoordinator {
    static func mock(
        interactor: Interactor = .mock(),
        viewFactory: ViewFactory = .mock(),
        sceneProvider: SceneProvider? = nil,
        engagementKind: EngagementKind = .audioCall,
        features: Features = .all,
        chatStorageState: @escaping () -> ChatStorageState,
        environment: Environment = .mock
    ) -> RootCoordinator {
        RootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            features: features,
            chatStorageState: chatStorageState,
            environment: environment
        )
    }
}
#endif
