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

    func test__deprecated_start_passes_all_arguments_to_interactor() throws {
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.reportDeprecatedMethodClosure = { _, _, _, _ in }
        logger.remoteLoggerClosure = { logger }
        logger.oneTimeClosure = { logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.print = .mock
        gliaEnv.processInfo.info = { [:] } 
        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { _ in }
        gliaEnv.proximityManager = .init(environment: proximityManagerEnv)
        gliaEnv.notificationCenter.removeObserverClosure = { _ in }
        gliaEnv.notificationCenter.removeObserverWithNameAndObject = { _, _, _ in }
        gliaEnv.notificationCenter.addObserverClosure = { _, _, _, _ in }
        var fileManager = FoundationBased.FileManager.failing
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        gliaEnv.fileManager = fileManager
        gliaEnv.coreSdk.configureWithInteractor = { _ in }
        gliaEnv.createFileUploadListModel = { _ in .mock() }
        gliaEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        gliaEnv.coreSdk.authentication = { _ in .mock }
        gliaEnv.coreSdk.queueForEngagement = { _, callback in
            callback(.success(.mock))
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.isAuthenticated = { return false }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.fetchSiteConfigurations = { _ in }
        gliaEnv.uuid = { .mock }
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.queuesMonitor = .mock()

        let expectedTheme = Theme.mock(
            colorStyle: .custom(.init()),
            fontStyle: .default,
            showsPoweredBy: true
        )
        let expectedFeatures: Features = [Features.bubbleView]
        var receivedTheme: Theme?
        var receivedFeatures = Features.init()

        let expectedSceneProvider = MockedSceneProvider()
        var receivedSceneProvider: SceneProvider?
        gliaEnv.createRootCoordinator = { interactor, viewFactory, sceneProvider, _, screenShareHandler, features, environment in
            receivedTheme = viewFactory.theme
            receivedFeatures = features
            receivedSceneProvider = sceneProvider
            return .mock(
                interactor: interactor,
                viewFactory: viewFactory,
                sceneProvider: sceneProvider,
                screenShareHandler: screenShareHandler,
                environment: environment
            )
        }

        let sdk = Glia(environment: gliaEnv)

        try sdk.start(
            .audioCall,
            configuration: .mock(),
            queueID: "queueId",
            theme: expectedTheme,
            features: .all,
            sceneProvider: expectedSceneProvider
        )

        XCTAssertTrue(try XCTUnwrap(receivedTheme) === expectedTheme)
        XCTAssertEqual(receivedFeatures, expectedFeatures)
        XCTAssertTrue(try XCTUnwrap(receivedSceneProvider as? MockedSceneProvider) === expectedSceneProvider)
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

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
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

        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
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

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }

        sdk.callVisualizer.coordinator.showEndScreenSharingViewController()
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

        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }

        sdk.callVisualizer.coordinator.showVideoCallViewController()
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
        let gliaVC = GliaViewController.mock(delegate: delegate)
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
        let gliaVC = GliaViewController.mock(delegate: delegate)
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
        var engCoordEnvironment = EngagementCoordinator.Environment.engagementCoordEnvironmentWithKeyWindow
        engCoordEnvironment.fileManager = .mock
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in EngagementCoordinator.mock(environment: engCoordEnvironment) }
        environment.queuesMonitor = .mock()

        let sdk = Glia(environment: environment)
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
        try sdk.startEngagement(
            engagementKind: .chat,
            in: ["mockedQueueId"]
        )
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
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
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
            secureConversationsWelcomeScreen: nil,
            secureConversationsConfirmationScreen: nil,
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
}
