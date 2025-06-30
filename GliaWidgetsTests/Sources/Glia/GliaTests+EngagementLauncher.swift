@testable import GliaWidgets
import XCTest

extension GliaTests {
    func test_getEngagementLauncherDoesNotThrowErrorWithCorrectConfiguration() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        XCTAssertNoThrow(
            try sdk.getEngagementLauncher(queueIds: [])
        )
    }

    func test_startChatUsingEngagementLauncherWithCorrectConfiguration() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startChat()

        XCTAssertEqual(sdk.engagement, .chat)
    }

    func test_startAudioCallUsingEngagementLauncherWithCorrectConfiguration() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])
        
        try engagementLauncher.startAudioCall()

        XCTAssertEqual(sdk.engagement, .audioCall)
    }
    
    func test_startVideoCallUsingEngagementLauncherWithCorrectConfiguration() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startVideoCall()

        XCTAssertEqual(sdk.engagement, .videoCall)
    }
    
    func test_startSecureConversationUsingEngagementLauncherWithCorrectConfiguration() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        sdk.environment.isAuthenticated = { true }

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startSecureMessaging()

        XCTAssertEqual(sdk.engagement, .messaging(.welcome))
    }

    func test_startSecureConversationThrowsErrorWhenVisitorIsUnauthenticated() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        XCTAssertThrowsError(try engagementLauncher.startSecureMessaging()) { error in
            XCTAssertEqual(error as? GliaError, GliaError.messagingIsNotSupportedForUnauthenticatedVisitor)
        }
    }
}

// MARK: - Enqueuing engagement with ongoing CV
extension GliaTests {
    func test_testEnqueuingChatWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .chat)
    }

    func test_testEnqueuingSCWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .messaging(.welcome))
    }
    
    func test_testEnqueuingAudioWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer), enqueueingEngagement: .videoCall)
    }
    
    func test_testEnqueuingChatWhenVideoCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .chat)
    }

    func test_testEnqueuingSCWhenVideoCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .messaging(.welcome))
    }
    
    func test_testEnqueuingAudioWhenVideoCallVisualizerIsActiveShouldShowSnackbar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenVideoCallVisualizerIsActiveShouldRestoreVideo() throws {
        var calledCVEvents: [CallVisualizer.Coordinator.DelegateEvent] = []

        let sdk = try makeConfigurableSDK(ongoingEngagement: .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .videoCall) { sdk in
            sdk.rootCoordinator?.gliaViewController = .mock()
            sdk.environment.snackBar.present = { _, _, _, _, _, _, _ in
            }
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
private extension GliaTests {
    func test_testEnqueuingChatWhenOngoingVideoEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: nil, video: .oneWay)), enqueueingEngagement: .chat)
    }

    func test_testEnqueuingSCWhenOngoingVideoEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: nil, video: .twoWay)), enqueueingEngagement: .messaging(.welcome))
    }

    func test_testEnqueuingChatWhenOngoingAudioEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: .twoWay, video: nil)), enqueueingEngagement: .chat)
    }
    
    func test_testEnqueuingSCWhenOngoingAudioEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement, media: .init(audio: .twoWay, video: nil)), enqueueingEngagement: .messaging(.welcome))
    }
    
    func test_testEnqueuingAudioWhenOngoingChatEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement), enqueueingEngagement: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenOngoingChatEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(ongoingEngagement: .mock(source: .coreEngagement), enqueueingEngagement: .videoCall)
    }
    
    func testSnackBarPresentation(ongoingEngagement: CoreSdkClient.Engagement, enqueueingEngagement: EngagementKind) throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = try makeConfigurableSDK(ongoingEngagement: ongoingEngagement, enqueueingEngagement: enqueueingEngagement) { sdk in
            sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
                snackBarMessage = message
                calls.append(.presentSnackBar)
            }
        }

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func makeConfigurableSDK(
        ongoingEngagement: CoreSdkClient.Engagement,
        enqueueingEngagement: EngagementKind,
        extendedConfigure: @escaping (Glia) -> ()
    ) throws -> Glia {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

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
    func test_testEnqueuingChatWhenEnqueuedChatEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .chat, engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedChatEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .messaging(.welcome), engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingChatWhenEnqueuedMessagingEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .chat, engagementToEnqueue: .messaging(.welcome))
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedMessagingEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .messaging(.welcome), engagementToEnqueue: .messaging(.welcome))
    }
    
    func test_testEnqueuingChatWhenEnqueuedAudioEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .chat, engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedAudioEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .messaging(.welcome), engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingChatWhenEnqueuedVideoEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .chat, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingMessagingWhenEnqueuedVideoEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .chat, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedAudioEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingVideoWhenEnqueuedAudioEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .audioCall)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedVideoEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingVideoWhenEnqueuedVideoEngagementExistsShouldMaximizeBubble() throws {
        try testBubbleRestoration(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .videoCall)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedChatEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingVideoWhenEnqueuedChatEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .chat)
    }
    
    func test_testEnqueuingAudioWhenEnqueuedMessagingEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .audioCall, engagementToEnqueue: .messaging(.welcome))
    }
    
    func test_testEnqueuingVideoWhenEnqueuedMessagingEngagementExistsShouldShowSnackBar() throws {
        try testSnackBarPresentation(enqueueingEngagementKind: .videoCall, engagementToEnqueue: .messaging(.welcome))
    }
    
    private func testBubbleRestoration(
        enqueueingEngagementKind: EngagementKind,
        engagementToEnqueue: EngagementKind
    ) throws {
        let delegate = GliaViewControllerDelegateMock()
        
        let sdk = try makeConfigurableSDK(
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
    ) throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?
        
        let sdk = try makeConfigurableSDK(
            enqueueingEngagementKind: enqueueingEngagementKind,
            engagementToEnqueue: engagementToEnqueue
        ) { sdk in
            sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
                snackBarMessage = message
                calls.append(.presentSnackBar)
            }
        }
        
        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    private func makeConfigurableSDK(
        enqueueingEngagementKind: EngagementKind,
        engagementToEnqueue: EngagementKind,
        extendedConfigure: @escaping (Glia) -> ()
    ) throws -> Glia {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

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
        sdkEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _ in
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
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        sdkEnv.isAuthenticated = { false }
        sdkEnv.coreSdk.getCurrentEngagement = { nil }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let window = UIWindow(frame: .zero)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: sdkEnv)
        sdk.queuesMonitor = .mock()
        return sdk
    }
}
