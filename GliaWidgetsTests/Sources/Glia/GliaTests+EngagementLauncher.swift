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

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        try engagementLauncher.startSecureMessaging()

        XCTAssertEqual(sdk.engagement, .messaging(.welcome))
    }

    func test_testEnqueuingToChatWhenAlreadyEnqueuedToChat() throws {
        enum Call {
            case maximize
        }
        var calls: [Call] = []

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()
        interactor.state = .enqueued(.mock, .chat)

        sdk.interactor = interactor
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = GliaViewController.mock(delegate: { event in
            switch event {
            case .maximized:
                calls.append(.maximize)
            default:
                break
            }
        })

        sdk.resolveEngagementState(
            engagementKind: .chat,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.maximize])
    }
}

// MARK: - Enqueuing engagement with ongoing CV
extension GliaTests {
    func test_testEnqueuingChatWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .callVisualizer)
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .chat,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingAudioWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .callVisualizer)
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .audioCall,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingVideoWhenCallVisualizerIsActiveShouldShowSnackbar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .callVisualizer)
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .videoCall,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingChatWhenVideoCallVisualizerIsActiveShouldRestoreVideo() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .chat,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingAudioWhenVideoCallVisualizerIsActiveShouldRestoreVideo() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .audioCall,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingVideoWhenVideoCallVisualizerIsActiveShouldRestoreVideo() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { _, _, _, _, _, _, _ in
        }
        var callVisualizerEnv = CallVisualizer.Environment.mock
        callVisualizerEnv.getCurrentEngagement = {
            .mock(source: .callVisualizer, media: .init(audio: nil, video: .oneWay))
        }
        sdk.callVisualizer = .init(environment: callVisualizerEnv)
        var calledEvents: [CallVisualizer.Coordinator.DelegateEvent] = []
        sdk.callVisualizer.coordinator.environment.eventHandler = { calledEvents.append($0) }

        sdk.resolveEngagementState(
            engagementKind: .videoCall,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertTrue(calledEvents.contains(.maximized))
    }
}

// MARK: - Enqueuing engagement with ongoing engagement
private extension GliaTests {
    func test_testEnqueuingChatWhenOngoingVideoEngagementExistsShouldShowSnackBar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .coreEngagement, media: .init(audio: nil, video: .oneWay))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .chat,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }

    func test_testEnqueuingSCWhenOngoingVideoEngagementExistsShouldShowSnackBar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .coreEngagement, media: .init(audio: nil, video: .oneWay))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .messaging(.welcome),
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }

    func test_testEnqueuingChatWhenOngoingAudioEngagementExistsShouldShowSnackBar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .coreEngagement, media: .init(audio: .twoWay, video: nil))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .chat,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingSCWhenOngoingAudioEngagementExistsShouldShowSnackBar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .coreEngagement, media: .init(audio: .twoWay, video: nil))
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .chat,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingAudioWhenOngoingChatEngagementExistsShouldShowSnackBar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .coreEngagement)
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .audioCall,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
    }
    
    func test_testEnqueuingVideoWhenOngoingChatEngagementExistsShouldShowSnackBar() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?

        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        let interactor: Interactor = .mock()

        sdk.interactor = interactor
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(source: .coreEngagement)
        }
        sdk.rootCoordinator = .mock(interactor: interactor)
        sdk.rootCoordinator?.gliaViewController = .mock()
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        sdk.resolveEngagementState(
            engagementKind: .videoCall,
            sceneProvider: .none,
            configuration: .mock(),
            interactor: interactor,
            features: .all,
            viewFactory: .mock(),
            ongoingEngagementMediaStreams: .none
        )

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
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
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        sdkEnv.coreSdk.getCurrentEngagement = { nil }
        sdkEnv.coreSdk.getSecureUnreadMessageCount = { $0(.success(0)) }
        sdkEnv.coreSdk.pendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.subscribeForUnreadSCMessageCount = { _ in nil }
        sdkEnv.coreSdk.observePendingSecureConversationStatus = { _ in nil }
        sdkEnv.coreSdk.unsubscribeFromPendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.unsubscribeFromUnreadCount = { _ in }
        let window = UIWindow(frame: .zero)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: sdkEnv)
        sdk.queuesMonitor = .mock()
        return sdk
    }
}
