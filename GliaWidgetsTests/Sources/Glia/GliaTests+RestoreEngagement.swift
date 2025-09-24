@testable import GliaWidgets
import XCTest

extension GliaTests {
    @MainActor
    func test_skipLiveObservationConfirmations() async throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let rootCoordinator = EngagementCoordinator.mock(
            engagementLaunching: .direct(kind: .chat),
            environment: .engagementCoordEnvironmentWithKeyWindow
        )
        sdkEnv.createRootCoordinator = { _, _, _, _, _, _, _ in
            rootCoordinator
        }
        sdkEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        sdkEnv.coreSdk.createLogger = { _ in logger }
        sdkEnv.gcd.mainQueue.async = { $0() }
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { siteMock }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        enum Call {
            case snackBarPresent
        }

        var calls: [Call] = []
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.snackBarPresent)
        }
        DependencyContainer.current.widgets.snackBar = snackBar

        sdkEnv.coreSdk.getQueues = { [] }
        sdkEnv.coreSdk.subscribeForQueuesUpdates = { _, _ in
            return UUID.mock.uuidString
        }

        let sdk = Glia(environment: sdkEnv)
        sdk.rootCoordinator = rootCoordinator

        try sdk.configure(with: .mock(), features: .all) { _ in }
        sdk.stringProvidingPhase = .configured { _ in
            return ""
        }
        guard let interactor = sdk.interactor else {
            XCTFail("Interactor missing")
            return
        }

        let engagement = CoreSdkClient.Engagement.mock()
        await sdk.restoreOngoingEngagement(
            configuration: .mock(),
            currentEngagement: engagement,
            interactor: interactor,
            features: .all,
            maximize: false
        )
        

        try XCTAssertTrue(XCTUnwrap(sdk.interactor?.skipLiveObservationConfirmations))
        XCTAssertEqual(calls, [.snackBarPresent])

        // end restored engagement
        sdk.interactor?.end(with: .visitorHungUp)

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startChat()

        try XCTAssertFalse(XCTUnwrap(sdk.interactor?.skipLiveObservationConfirmations))
    }

    func test_restoreOngoingIfPresentShouldNotRestoreIfCoordinatorisPresent() throws {
        // CoreSDK mock
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let rootCoordinator = EngagementCoordinator.mock(
            engagementLaunching: .direct(kind: .chat),
            environment: .engagementCoordEnvironmentWithKeyWindow
        )
        sdkEnv.createRootCoordinator = { _, _, _, _, _, _, _ in
            rootCoordinator
        }
        sdkEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        sdkEnv.coreSdk.createLogger = { _ in logger }
        sdkEnv.gcd.mainQueue.async = { $0() }
        sdkEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { callback in callback(.success(siteMock)) }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        sdkEnv.coreSdk.getQueues = { callback in callback(.success([])) }
        sdkEnv.coreSdk.subscribeForQueuesUpdates = { _, _ in
            return UUID.mock.uuidString
        }
        let engagement = CoreSdkClient.Engagement.mock()
        let engagmentStarted = Boxed<Bool>(value: false)
        sdkEnv.coreSdk.getCurrentEngagement = { [engagmentStarted] in
            engagmentStarted.value ? engagement : nil
        }

        // WidgetSDK
        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in }

        // Start chat engagement
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startChat()
        engagmentStarted.value = true

        // try restore
        sdk.restoreOngoingEngagementIfPresent()

        XCTAssertNotEqual(sdk.engagementRestorationState, .restored)
    }

    func test_restoreOngoingIfPresentShouldNotRestoreIfWeAlreadyRestoring() throws {
        // CoreSDK mock
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let rootCoordinator = EngagementCoordinator.mock(
            engagementLaunching: .direct(kind: .chat),
            environment: .engagementCoordEnvironmentWithKeyWindow
        )
        sdkEnv.createRootCoordinator = { _, _, _, _, _, _, _ in
            rootCoordinator
        }
        sdkEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        sdkEnv.coreSdk.createLogger = { _ in logger }
        sdkEnv.gcd.mainQueue.async = { $0() }
        sdkEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { callback in callback(.success(siteMock)) }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        sdkEnv.coreSdk.getQueues = { callback in callback(.success([])) }
        sdkEnv.coreSdk.subscribeForQueuesUpdates = { _, _ in
            return UUID.mock.uuidString
        }
        let engagement = CoreSdkClient.Engagement.mock()
        let configured = Boxed<Bool>(value: false)
        sdkEnv.coreSdk.getCurrentEngagement = { [configured] in
            configured.value ? engagement : nil
        }

        // WidgetSDK
        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in
            configured.value = true
        }

        // Set restoring engagement state
        sdk.engagementRestorationState = .restoring

        // try restore
        sdk.restoreOngoingEngagementIfPresent()

        XCTAssertNotEqual(sdk.engagementRestorationState, .restored)
    }

    func test_restoreOngoingSecureConversationEngagement() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
            EngagementCoordinator.mock(
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
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { siteMock }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let uuidGen = UUID.incrementing
        sdkEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in uuidGen().uuidString }
        sdkEnv.gcd.mainQueue.async = { $0() }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        enum Call {
            case snackBarPresent
            case engagementStarted
            case minimized
        }

        var calls: [Call] = []
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.snackBarPresent)
        }
        DependencyContainer.current.widgets.snackBar = snackBar

        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
        sdk.stringProvidingPhase = .configured { _ in
            return ""
        }
        sdk.onEvent = { event in
            switch event {
            case .started:
                calls.append(.engagementStarted)
            case .minimized:
                calls.append(.minimized)
            default:
                XCTFail("Unexpected event received")
            }
        }
        guard let interactor = sdk.interactor else {
            XCTFail("Interactor missing")
            return
        }
        interactor.state = .engaged(.mock())

        // Will be removed when async state observing is implemented
        await waitUntil {
            sdk.rootCoordinator?.gliaViewController != nil
        }
        XCTAssertNotNil(sdk.rootCoordinator?.gliaViewController)
        XCTAssertEqual(calls, [.engagementStarted, .minimized, .snackBarPresent])
    }

    func test_sdkDoesNotRestoreOngoingTransferredSecureConversation() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.createRootCoordinator = { _, _, _, _, _, _, _ in
            XCTFail("SDK should not create root coordinator")
            return .mock()
        }
        sdkEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        sdkEnv.coreSdk.createLogger = { _ in logger }
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { siteMock }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let uuidGen = UUID.incrementing
        sdkEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in uuidGen().uuidString }
        sdkEnv.gcd.mainQueue.async = { $0() }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }

        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            XCTFail("SDK should not present snackBar")
        }
        DependencyContainer.current.widgets.snackBar = snackBar

        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(status: .transferring, capabilities: .init(text: true))
        }
        sdk.stringProvidingPhase = .configured { _ in
            return ""
        }
        sdk.onEvent = { event in
            XCTFail("Unexpected event received")
        }
        guard let interactor = sdk.interactor else {
            XCTFail("Interactor missing")
            return
        }
        interactor.state = .engaged(.mock())

        XCTAssertNil(sdk.rootCoordinator?.gliaViewController)
    }

    @MainActor
    func test_sdkRestoresMessagingWhenOngoingEngagementExistsAndPendingInteractionIsTrue() async throws {
        enum Call {
            case snackBarPresent
            case engagementStarted
            case minimized
            case maximized
        }
        var calls: [Call] = []
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        var launching: EngagementCoordinator.EngagementLaunching?
        sdkEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
            launching = engagementLaunching
            return EngagementCoordinator.mock(
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
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { siteMock }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }

        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.snackBarPresent)
        }
        DependencyContainer.current.widgets.snackBar = snackBar

        let uuidGen = UUID.incrementing
        sdkEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { callback in
            callback(.success(true))
            return uuidGen().uuidString
        }
        sdkEnv.gcd.mainQueue.async = { $0() }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }

        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
        sdk.stringProvidingPhase = .configured { _ in
            return ""
        }
        sdk.onEvent = { event in
            switch event {
            case .started:
                calls.append(.engagementStarted)
            case .minimized:
                calls.append(.minimized)
            default:
                XCTFail("Unexpected event received")
            }
        }
        guard let interactor = sdk.interactor else {
            XCTFail("Interactor missing")
            return
        }
        interactor.state = .engaged(.mock())

        // Will be removed when async state observing is implemented
        await waitUntil {
            sdk.rootCoordinator?.gliaViewController != nil
        }
        XCTAssertNotNil(sdk.rootCoordinator?.gliaViewController)
        XCTAssertEqual(launching, .direct(kind: .messaging(.chatTranscript)))
        XCTAssertEqual(calls, [.engagementStarted, .minimized, .snackBarPresent])
    }
}
