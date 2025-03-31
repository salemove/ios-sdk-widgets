import GliaCoreSDK
import XCTest

@testable import GliaWidgets

final class GliaTests: XCTestCase {
    func test__endEngagementNotConfigured() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { false }

        let sdk = Glia(environment: environment)
        sdk.endEngagement { result in
            guard case .failure(let error) = result, let gliaError = error as? GliaError else {
                XCTFail("GliaError.sdkIsNotConfigured expected.")
                return
            }
            XCTAssertEqual(gliaError, GliaError.sdkIsNotConfigured)
        }
    }

    func test__endEngagement() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { false }

        let sdk = Glia(environment: environment)
        sdk.interactor = .mock()
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        sdk.endEngagement { _ in }

        XCTAssertEqual(calls, [.onEvent(.ended)])
        XCTAssertNil(sdk.rootCoordinator)
    }

    func test__messageRenderer() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }

        let sdk = Glia(environment: environment)
        XCTAssertNotNil(sdk.messageRenderer)

        sdk.setChatMessageRenderer(messageRenderer: nil)

        XCTAssertNil(sdk.messageRenderer)
    }

    func testOnEventWhenCallVisualizerEngagementStarts() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.fetchSiteConfigurations = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        sdk.callVisualizer.delegate?(.engagementStarted)
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }

        sdk.interactor?.state = .engaged(nil)

        XCTAssertEqual(calls, [.onEvent(.started)])
    }

    func testOnEventWhenCallVisualizerEngagementEnds() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.configureWithConfiguration = { _, _ in }
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(calls, [.onEvent(.ended)])
    }

    func testInteractorEventsAreObservedForCallVisualizer() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.configureWithConfiguration = { _, _ in }
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.interactor?.state = .engaged(.mock())

        XCTAssertEqual(calls, [])

        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        /// Since interactor is created only after visitor code is requested, 
        /// we can be sure that if this test succeeds, interactor observer is
        /// added successfully, because observer method is called during
        /// interactor creation.

        XCTAssertEqual(calls, [.onEvent(.ended)])
    }

    func testOnEventWhenScreenSharingScreenIsShownAndCallVisualizerEngagementEnds() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.print = .mock
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.callVisualizer.coordinator.showEndScreenSharingViewController()
        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(calls, [.onEvent(.minimized), .onEvent(.ended)])
    }

    func testOnEventWhenVideoScreenIsShownAndCallVisualizerEngagementEnds() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { _ in }
        gliaEnv.proximityManager = .init(environment: proximityManagerEnv)
        gliaEnv.uuid = { .mock }
        gliaEnv.uiApplication.windows = { [] }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.notificationCenter.addObserverClosure = { _, _, _, _ in }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.callVisualizer.coordinator.showVideoCallViewController()
        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(calls, [.onEvent(.maximized), .onEvent(.minimized), .onEvent(.ended)])
    }

    func testConfigureThrowsErrorDuringActiveEngagement() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSdk.getCurrentEngagement = { .mock() }
        let sdk = Glia(environment: environment)

        XCTAssertThrowsError(try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }) { error in
            XCTAssertEqual(error as? GliaError, GliaError.configuringDuringEngagementIsNotAllowed)
        }
    }

    func testConfigureSetsFeaturesFieldPassedAsParameter() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)
        try sdk.configure(
            with: .mock(),
            features: .bubbleView
        ) { _ in }
        XCTAssertEqual(sdk.features, .bubbleView)
        try sdk.configure(
            with: .mock(),
            features: []
        ) { _ in }
        XCTAssertEqual(sdk.features, [])
        try sdk.configure(
            with: .mock(),
            features: .all
        ) { _ in }
        XCTAssertEqual(sdk.features, .all)
    }

    func testClearVisitorSessionThrowsErrorDuringActiveEngagement() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSdk.getCurrentEngagement = { .mock() }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)

        var resultingError: Error?
        sdk.clearVisitorSession { result in
            guard case let .failure(error) = result else {
                fail("`clearVisitorSession` should fail when ongoing engegament exists.")
                return
            }
            resultingError = error
        }

        XCTAssertEqual(resultingError as? GliaError, GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed)
    }

    func test_minimize() {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        let sdk = Glia(environment: environment)
        let coordinator = EngagementCoordinator.mock()
        let delegate = GliaViewControllerDelegateMock()
        let gliaVC = GliaViewController.mock(delegate: { event in
            delegate.event(event)
        })
        coordinator.gliaViewController = gliaVC
        sdk.rootCoordinator = coordinator

        sdk.minimize()

        XCTAssertTrue(delegate.invokedEventCall)
        XCTAssertEqual(delegate.invokedEventCallCount, 1)
        XCTAssertEqual(delegate.invokedEventCallParameter, .minimized)
        XCTAssertEqual(delegate.invokedEventCallParameterList, [.minimized])
    }

    func test_maximize() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        let sdk = Glia(environment: environment)
        let coordinator = EngagementCoordinator.mock()
        let delegate = GliaViewControllerDelegateMock()
        let gliaVC = GliaViewController.mock(delegate: { event in
            delegate.event(event)
        })
        coordinator.gliaViewController = gliaVC
        sdk.rootCoordinator = coordinator

        try sdk.resume()

        XCTAssertTrue(delegate.invokedEventCall)
        XCTAssertEqual(delegate.invokedEventCallCount, 1)
        XCTAssertEqual(delegate.invokedEventCallParameter, .maximized)
        XCTAssertEqual(delegate.invokedEventCallParameterList, [.maximized])
    }

    func test_isConfiguredIsInitiallyFalse() {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }

        XCTAssertFalse(Glia(environment: environment).isConfigured)
    }

    func test_isConfiguredIsTrueWhenConfigurationPerformed() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        XCTAssertTrue(sdk.isConfigured)
        XCTAssertNotNil(sdk.interactor)
    }

    func test_isConfiguredIsTrueWhenConfigurationPerformedDuringTransferredSC() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        environment.coreSdk.getCurrentEngagement = { .mock(status: .transferring, capabilities: .init(text: true)) }
        let sdk = Glia(environment: environment)
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        XCTAssertTrue(sdk.isConfigured)
        XCTAssertNotNil(sdk.interactor)
    }

    func test_interactorIsInitializedAfterConfiguration() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        XCTAssertNotNil(sdk.interactor)
    }

    func test_isConfiguredIsFalseWhenSecondConfigureCallThrowsError() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        var isFirstConfigure = true
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            if isFirstConfigure {
                isFirstConfigure = false
                completion(.success(()))
            } else {
                throw CoreSdkClient.GliaCoreError.mock()
            }
        }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        XCTAssertTrue(sdk.isConfigured)

        try? sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        XCTAssertFalse(sdk.isConfigured)
    }

    func test_isConfiguredIsFalseWhenConfigureWithConfigurationThrowsError() {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, _ in
            throw CoreSdkClient.GliaCoreError.mock()
        }
        let sdk = Glia(environment: environment)
        try? sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        XCTAssertFalse(sdk.isConfigured)
    }

    func test_engagementCoordinatorGetsDeallocated() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, callback in
            callback(.success(()))
        }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        var engCoordEnvironment = EngagementCoordinator.Environment.engagementCoordEnvironmentWithKeyWindow
        engCoordEnvironment.fileManager = .mock
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in EngagementCoordinator.mock(environment: engCoordEnvironment) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        enum Call {
            case configureWithConfiguration
        }
        var calls: [Call] = []
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in
            calls.append(.configureWithConfiguration)
        }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"])
        try engagementLauncher.startChat()
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        var endEngagementResult: Result<Void, Error>?
        sdk.endEngagement { result in
            endEngagementResult = result
        }
        XCTAssertNoThrow(try XCTUnwrap(endEngagementResult))
        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
    }

    func test_screenSharingIsStoppedWhenCallVisualizerEngagementIsEnded() throws {
        enum Call { case ended }
        var calls: [Call] = []
        var gliaEnv = Glia.Environment.failing
        gliaEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        let screenShareHandler: ScreenShareHandler = .mock
        screenShareHandler.status().value = .started
        gliaEnv.screenShareHandler = screenShareHandler
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, callback in
            callback(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.onEvent = { event in
            switch event {
            case .ended:
                calls.append(.ended)
            default:
                XCTFail("There is should be no another event")
            }
        }
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(screenShareHandler.status().value, .stopped)
        XCTAssertEqual(calls, [.ended])
    }

    func test_remoteConfigIsAppliedToThemeUponConfigure() throws {
        let themeColor: ThemeColor = .init(
            primary: .red,
            systemNegative: .red
        )

        let globalColors: RemoteConfiguration.GlobalColors = .init(
            primary: "#00FF00",
            secondary: "#00FF00",
            baseNormal: "#00FF00",
            baseLight: "#00FF00",
            baseDark: "#00FF00",
            baseShade: "#00FF00",
            systemNegative: "#00FF00",
            baseNeutral: "#00FF00"
        )

        let uiConfig: RemoteConfiguration = .init(
            globalColors: globalColors,
            callScreen: nil,
            chatScreen: nil,
            surveyScreen: nil,
            alert: nil,
            bubble: nil,
            callVisualizer: nil,
            secureMessagingWelcomeScreen: nil,
            secureMessagingConfirmationScreen: nil,
            snackBar: nil,
            webBrowserScreen: nil,
            entryWidget: nil
        )

        let theme = Theme(colorStyle: .custom(themeColor))
        var environment = Glia.Environment.failing
        environment.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.remoteLoggerClosure = { logger }
        var prefixes: [String] = []
        logger.prefixedClosure = { prefixValue in
            prefixes.append(prefixValue)
            return logger
        }

        logger.oneTimeClosure = { logger }
        var messages: [String] = []
        logger.infoClosure = { message, _, _, _ in
            messages.append("\(message)")
        }

        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)
        let configuration = Configuration.mock()

        try sdk.configure(
            with: configuration,
            theme: theme,
            uiConfig: uiConfig
        ) { _ in }

        let primaryColorHex = sdk.theme.color.primary.toRGBAHex(alpha: false)
        let systemNegativeHex = sdk.theme.color.systemNegative.toRGBAHex(alpha: false)
        XCTAssertEqual(primaryColorHex, "#00FF00")
        XCTAssertEqual(systemNegativeHex, "#00FF00")
        XCTAssertEqual(prefixes, ["Glia", "Glia"])
        XCTAssertEqual(messages, ["Initialize Glia Widgets SDK", "Setting Unified UI Config"])
    }

    func test_hasPendingInteractionIfPendingSecureConversationExists() throws {
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        let uuidGen = UUID.incrementing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { callback in
            callback(.success(0))
            return uuidGen().uuidString
        }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { callback in
            callback(.success(true))
            return uuidGen().uuidString
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }

        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        XCTAssertTrue(try XCTUnwrap(sdk.pendingInteraction).hasPendingInteraction)
    }

    func test_hasPendingInteractionIfUnreadMessagesExist() throws {
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        let uuidGen = UUID.incrementing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { callback in
            callback(.success(3))
            return uuidGen().uuidString
        }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { callback in
            callback(.success(false))
            return uuidGen().uuidString
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }

        let sdk = Glia(environment: gliaEnv)

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        XCTAssertTrue(try XCTUnwrap(sdk.pendingInteraction).hasPendingInteraction)
    }

    func test_hasPendingInteractionIfNoUnreadMessageAndPendingSecureConversationExist() throws {
        let uuidGen = UUID.incrementing
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.coreSdk.secureConversations.pendingStatus = { $0(.success(false)) }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { _ in uuidGen().uuidString }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in uuidGen().uuidString }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }

        let sdk = Glia(environment: gliaEnv)

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        XCTAssertFalse(try XCTUnwrap(sdk.pendingInteraction).hasPendingInteraction)
    }

    func test_deauthenticateErasesInteractorState() throws {
        var uuidGen = UUID.incrementing
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.coreSdk.secureConversations.pendingStatus = { $0(.success(false)) }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { _ in uuidGen().uuidString }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in uuidGen().uuidString }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let authentication = CoreSdkClient.Authentication(deauthenticateWithCallback: { callback in
            callback(.success(()))
        })
        gliaEnv.coreSdk.authentication = { _ in authentication }
        gliaEnv.coreSdk.requestEngagedOperator = { $0([], nil) }
        gliaEnv.gcd.mainQueue.async = { $0() }
        gliaEnv.coreSdk.fetchSiteConfigurations = { _ in }
        gliaEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        gliaEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
            EngagementCoordinator.mock(
                engagementLaunching: engagementLaunching,
                screenShareHandler: .mock,
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }

        let sdk = Glia(environment: gliaEnv)

        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
            completion(.success(()))
        }

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.interactor?.start()

        XCTAssertEqual(sdk.interactor?.state, .engaged(nil))

        try sdk.authentication(with: .allowedDuringEngagement)
            .deauthenticate { _ in }

        XCTAssertEqual(try XCTUnwrap(sdk.interactor?.state), .none)
    }
}
