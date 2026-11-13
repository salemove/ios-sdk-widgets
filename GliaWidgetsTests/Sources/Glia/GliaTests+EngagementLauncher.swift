@testable import GliaWidgets
import XCTest

extension GliaTests {
    func test_getEngagementLauncherDoesNotThrowErrorWithCorrectConfiguration() async throws {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        XCTAssertNoThrow(
            try sdk.getEngagementLauncher(queueIds: [])
        )
    }

    func test_startChatUsingEngagementLauncherWithCorrectConfiguration() async throws {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startChat()

        XCTAssertEqual(sdk.engagement, .chat)
    }

    func test_startAudioCallUsingEngagementLauncherWithCorrectConfiguration() async throws {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])
        
        try engagementLauncher.startAudioCall()

        XCTAssertEqual(sdk.engagement, .audioCall)
    }
    
    func test_startVideoCallUsingEngagementLauncherWithCorrectConfiguration() async throws {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startVideoCall()

        XCTAssertEqual(sdk.engagement, .videoCall)
    }
    
    func test_startSecureConversationUsingEngagementLauncherWithCorrectConfiguration() async throws {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        sdk.environment.isAuthenticated = { true }

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startSecureMessaging()

        XCTAssertEqual(sdk.engagement, .messaging(.welcome))
    }

    func test_startSecureConversationThrowsErrorWhenVisitorIsUnauthenticated() async throws {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        XCTAssertThrowsError(try engagementLauncher.startSecureMessaging()) { error in
            XCTAssertEqual(error as? GliaError, GliaError.messagingIsNotSupportedForUnauthenticatedVisitor)
        }
    }
}

// MARK: - Enqueuing engagement with ongoing CV
extension GliaTests {
    func test_testEnqueuingChatWhenCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .chat)
    }

    func test_testEnqueuingSCWhenCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .messaging(.welcome))
    }
    
    func test_testEnqueuingAudioWhenCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .videoCall)
    }
    
    func test_testEnqueuingChatWhenVideoCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .chat)
    }

    func test_testEnqueuingSCWhenVideoCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .messaging(.welcome))
    }
    
    func test_testEnqueuingAudioWhenVideoCallVisualizerIsActiveShouldShowSnackbar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenVideoCallVisualizerIsActiveShouldRestoreVideo() async throws {
        var calledCVEvents: [CallVisualizer.Coordinator.DelegateEvent] = []

        _ = try await makeConfigurableSDK(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .videoCall) { sdk in
            sdk.rootCoordinator?.gliaViewController = .mock()
            var callVisualizerEnv = CallVisualizer.Environment.mock
            callVisualizerEnv.getCurrentEngagement = {
                .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay))
            }
            sdk.callVisualizer = .init(environment: callVisualizerEnv)
            sdk.callVisualizer.coordinator.environment.eventHandler = { calledCVEvents.append($0) }
        }
        XCTAssertTrue(calledCVEvents.contains(.maximized))
    }
}

// MARK: - Enqueuing engagement with ongoing engagement
extension GliaTests {
    func test_testEnqueuingChatWhenOngoingVideoEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .chat)
    }

    func test_testEnqueuingSCWhenOngoingVideoEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: nil, video: .twoWay)), enqueueingEngagement: .messaging(.welcome))
    }

    func test_testEnqueuingChatWhenOngoingAudioEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: .twoWay, video: nil)), enqueueingEngagement: .chat)
    }
    
    func test_testEnqueuingSCWhenOngoingAudioEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: .twoWay, video: nil)), enqueueingEngagement: .messaging(.welcome))
    }
    
    func test_testEnqueuingAudioWhenOngoingChatEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement), enqueueingEngagement: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenOngoingChatEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement), enqueueingEngagement: .videoCall)
    }
    
    func testSnackBarPresentation(ongoingEngagement: CoreSdkClient.Engagement, enqueueingEngagement: EngagementKind) async throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        var snackBar: SnackBar = .mock
        snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        _ = try await makeConfigurableSDK(ongoingEngagement: ongoingEngagement, enqueueingEngagement: enqueueingEngagement) { _ in }

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func makeConfigurableSDK(
        ongoingEngagement: CoreSdkClient.Engagement,
        enqueueingEngagement: EngagementKind,
        extendedConfigure: @escaping (Glia) -> ()
    ) async throws -> Glia {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            ongoingEngagement
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()

        extendedConfigure(sdk)

        try sdk.resolveEngagementState(
            engagementKind: enqueueingEngagement,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        return sdk
    }
}

// MARK: - Enqueuing engagement with enqueued engagement
extension GliaTests {
    func test_testEnqueuingChatWhenEnqueuedChatEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .chat, engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedChatEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .messaging(.welcome), engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingChatWhenEnqueuedMessagingEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .chat, engagementToEnqueue: .messaging(.welcome))
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedMessagingEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .messaging(.welcome), engagementToEnqueue: .messaging(.welcome))
    }
    
    func test_testEnqueuingChatWhenEnqueuedAudioEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .chat, engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedAudioEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .messaging(.welcome), engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingChatWhenEnqueuedVideoEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .chat, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedVideoEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .chat, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedAudioEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenEnqueuedAudioEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedVideoEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingVideoWhenEnqueuedVideoEngagementExistsShouldMaximizeBubble() async throws {
        try await testBubbleRestoration(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedChatEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingVideoWhenEnqueuedChatEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedMessagingEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .messaging(.welcome))
    }
    
    func test_testEnqueuingVideoWhenEnqueuedMessagingEngagementExistsShouldShowSnackBar() async throws {
        try await testSnackBarPresentation(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .messaging(.welcome))
    }
    
    private func testBubbleRestoration(
        enqueueingEngagementKind: EngagementKind,
        engagementToEnqueue: EngagementKind
    ) async throws {
        let delegate = GliaViewControllerDelegateMock()
        
        let _ = try await makeConfigurableSDK(
            enqueueingEngagementKind: enqueueingEngagementKind,
            engagementToEnqueue: engagementToEnqueue
        ) { sdk in
            let coordinator = EngagementCoordinator.mock()
            let gliaVC = GliaViewController.mock(delegate: { event in
                delegate.event(event)
            })
            coordinator.gliaViewController = gliaVC
            sdk.rootCoordinator = coordinator
        }
        
        XCTAssertEqual(delegate.invokedEventCallParameter, .maximized)
        XCTAssertEqual(delegate.invokedEventCallParameterList, [.maximized])
    }
    
    private func testSnackBarPresentation(
        enqueueingEngagementKind: EngagementKind,
        engagementToEnqueue: EngagementKind
    ) async throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?
        var snackBar: SnackBar = .mock
        snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        _ = try await makeConfigurableSDK(
            enqueueingEngagementKind: enqueueingEngagementKind,
            engagementToEnqueue: engagementToEnqueue
        ) { _ in }

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    private func makeConfigurableSDK(
        enqueueingEngagementKind: EngagementKind,
        engagementToEnqueue: EngagementKind,
        extendedConfigure: @escaping (Glia) -> ()
    ) async throws -> Glia {
        let sdk = makeConfigurableSDK()

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.interactor?.state = .enqueueing(enqueueingEngagementKind)
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()

        extendedConfigure(sdk)

        try sdk.resolveEngagementState(
            engagementKind: engagementToEnqueue,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        return sdk
    }
}

private extension GliaTests {
    func makeConfigurableSDK() -> Glia {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.coreSdk.localeProvider = .mock
        sdkEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
                .mock(
                    engagementLaunching: engagementLaunching,
                    environment: .engagementCoordEnvironmentWithKeyWindow
                )
        }
        sdkEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        sdkEnv.coreSdk.createLogger = { _ in logger }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        sdkEnv.isAuthenticated = { false }
        sdkEnv.coreSdk.getCurrentEngagement = { nil }
        sdkEnv.coreSdk.secureConversations.pendingSecureConversationStatusStream = { AsyncThrowingStream { $0.finish() } }
        let window = UIWindow(frame: .zero)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: sdkEnv)
        sdk.queuesMonitor = .mock()
        return sdk
    }
}
