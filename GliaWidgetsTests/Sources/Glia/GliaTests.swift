@_spi(GliaWidgets) internal import GliaCoreSDK
import XCTest

@testable import GliaWidgets

@MainActor
final class GliaTests: XCTestCase {
    func testUnreadCountSubscriptionFailureReturnsNilSynchronously() {
        var coreSdk = CoreSdkClient.mock
        coreSdk.secureConversations.subscribeForUnreadMessageCount = {
            throw GliaError.sdkIsNotConfigured
        }
        let secureConversations = SecureConversations(environment: .init(coreSdk: coreSdk))
        var error: GliaError?

        let token = secureConversations.subscribeSecureUnreadMessageCount { result in
            if case let .failure(failure) = result {
                error = failure as? GliaError
            }
        }

        XCTAssertNil(token)
        XCTAssertEqual(error, .sdkIsNotConfigured)
    }

    @MainActor
    func testUnreadCountSubscriptionDoesNotRetainItsStore() async {
        let terminated = expectation(description: "Unread count stream cancelled")
        var coreSdk = CoreSdkClient.mock
        coreSdk.secureConversations.subscribeForUnreadMessageCount = {
            AsyncThrowingStream { continuation in
                continuation.onTermination = { _ in terminated.fulfill() }
            }
        }
        var secureConversations: SecureConversations? = .init(environment: .init(coreSdk: coreSdk))
        weak var store = secureConversations?.environment.subscriptionStore
        XCTAssertNotNil(secureConversations?.subscribeSecureUnreadMessageCount { _ in })

        secureConversations = nil

        XCTAssertNil(store)
        await fulfillment(of: [terminated], timeout: 1)
    }

    @MainActor
    func testUnreadCountCallbacksRunOnMainThread() async {
        var coreSdk = CoreSdkClient.mock
        coreSdk.secureConversations.getUnreadMessageCount = { 3 }
        coreSdk.secureConversations.subscribeForUnreadMessageCount = {
            AsyncThrowingStream {
                $0.yield(3)
                $0.finish()
            }
        }
        let secureConversations = SecureConversations(environment: .init(coreSdk: coreSdk))
        let completed = expectation(description: "Unread count callbacks")
        completed.expectedFulfillmentCount = 2
        secureConversations.getUnreadMessageCount { result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(try? result.get(), 3)
            completed.fulfill()
        }
        let token = secureConversations.subscribeSecureUnreadMessageCount { result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(try? result.get(), 3)
            completed.fulfill()
        }

        await fulfillment(of: [completed], timeout: 1)
        if let token { secureConversations.unsubscribeSecureUnreadMessageCount(token) }
    }

    @MainActor
    func testAsyncConfigurePreparesUIOnMainThread() async throws {
        var environment = Glia.Environment.mock
        environment.coreSdk.getCurrentEngagement = {
            XCTAssertTrue(Thread.isMainThread)
            return nil
        }
        let sdk = Glia(environment: environment)
        let configuration = Configuration.mock()
        let theme = Theme.mock()

        try await Task.detached {
            try await sdk.configure(with: configuration, theme: theme)
        }.value
    }

    @MainActor
    func testCallbackAPIsCompleteOnMainThread() async {
        let sdk = Glia(environment: .mock)
        let completed = expectation(description: "Callback APIs completed")
        completed.expectedFulfillmentCount = 5
        let recordCompletion = {
            XCTAssertTrue(Thread.isMainThread)
            completed.fulfill()
        }

        sdk.clearVisitorSession { _ in recordCompletion() }
        sdk.getVisitorInfo { _ in recordCompletion() }
        sdk.updateVisitorInfo(.init()) { _ in recordCompletion() }
        sdk.endEngagement { _ in recordCompletion() }
        sdk.getQueues { _ in recordCompletion() }

        await fulfillment(of: [completed], timeout: 1)
    }

    @MainActor
    func testAuthenticationUsesMainThreadForOperationsAndCallbacks() async throws {
        let authentication = Glia.Authentication(
            authenticateWithIdToken: { _, _, callback in
                XCTAssertTrue(Thread.isMainThread)
                callback(.success(()))
            },
            deauthenticateWithCallback: { _, callback in
                XCTAssertTrue(Thread.isMainThread)
                callback(.success(()))
            },
            isAuthenticatedClosure: { false },
            refresh: { _, _, callback in
                XCTAssertTrue(Thread.isMainThread)
                callback(.success(()))
            },
            environment: .init(log: .mock)
        )

        try await Task.detached {
            try await authentication.authenticate(with: "token", accessToken: nil)
            try await authentication.deauthenticate()
            try await authentication.refresh(with: "token", accessToken: nil)
        }.value

        let completed = expectation(description: "Authentication callbacks completed")
        completed.expectedFulfillmentCount = 3
        let recordCompletion = {
            XCTAssertTrue(Thread.isMainThread)
            completed.fulfill()
        }
        authentication.authenticate(with: "token", accessToken: nil) { _ in recordCompletion() }
        authentication.deauthenticate { _ in recordCompletion() }
        authentication.refresh(with: "token", accessToken: nil) { _ in recordCompletion() }
        await fulfillment(of: [completed], timeout: 1)
    }

    @MainActor
    func testConfigurePreservesPendingInteractionSubscriptionFailure() async {
        var environment = Glia.Environment.mock
        environment.coreSdk.secureConversations.observePendingStatus = {
            throw GliaError.internalError
        }
        let sdk = Glia(environment: environment)

        do {
            try await sdk.configure(with: .mock(), theme: .mock())
            XCTFail("Configuration must fail when pending interaction observation cannot start")
        } catch {
            XCTAssertEqual(error as? GliaError, .internalEventSubscriptionFailure)
        }
    }

    @MainActor
    func testConfigureMapsCoreConfigurationFailure() async {
        var environment = Glia.Environment.mock
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            throw CoreSdkClient.ConfigurationProcessError.invalidSiteApiKeyCredentials
        }
        let sdk = Glia(environment: environment)

        do {
            try await sdk.configure(with: .mock(), theme: .mock())
            XCTFail("Configuration must fail when Core rejects the credentials")
        } catch {
            XCTAssertEqual(error as? GliaError, .invalidSiteApiKeyCredentials)
        }
    }

    func test__endEngagementNotConfigured() async throws {
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
        let completed = expectation(description: "End engagement completed")
        sdk.endEngagement { result in
            defer { completed.fulfill() }
            guard case .failure(let error) = result, let gliaError = error as? GliaError else {
                XCTFail("GliaError.sdkIsNotConfigured expected.")
                return
            }
            XCTAssertEqual(gliaError, GliaError.sdkIsNotConfigured)
        }
        await fulfillment(of: [completed], timeout: 1)
    }

    func test__endEngagement() async throws {
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
        environment.coreSdk.configureWithInteractor = { _ in }
        environment.coreSdk.configureWithConfiguration = { _ in }
        environment.gcd.mainQueue.async = { callback in callback() }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }

        let sdk = Glia(environment: environment)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        let completionExpectation = expectation(description: "endEngagement completion")
        var endEngagementResult: Result<Void, Error>?
        sdk.endEngagement { result in
            endEngagementResult = result
            completionExpectation.fulfill()
        }

        await fulfillment(of: [completionExpectation], timeout: 1)

        XCTAssertNoThrow(try XCTUnwrap(endEngagementResult).get())
        XCTAssertEqual(calls, [.onEvent(.ended)])
        XCTAssertNil(sdk.rootCoordinator)
    }

    func test__messageRenderer() async throws {
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

    func testOnEventWhenCallVisualizerEngagementStarts() async throws {
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
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.fetchSiteConfigurations = { try .mock() }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        sdk.callVisualizer.delegate?(.engagementStarted)
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }

        sdk.interactor?.state = .engaged(nil)

        XCTAssertEqual(calls, [.onEvent(.started)])
    }

    func testOnEventWhenCallVisualizerEngagementEnds() async throws {
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
        gliaEnv.coreSdk.configureWithConfiguration = { _ in }
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }

        let sdk = Glia(environment: gliaEnv)
        let ended = expectation(description: "Ended event")
        sdk.onEvent = {
            calls.append(.onEvent($0))
            if $0 == .ended {
                ended.fulfill()
            }
        }
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        await fulfillment(of: [ended], timeout: 1)
        XCTAssertEqual(calls, [.onEvent(.ended)])
    }

    func testInteractorEventsAreObservedForCallVisualizer() async throws {
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
        gliaEnv.coreSdk.configureWithConfiguration = { _ in }
        gliaEnv.gcd.mainQueue.async = { callback in callback() }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }

        let sdk = Glia(environment: gliaEnv)
        let ended = expectation(description: "Ended event")
        sdk.onEvent = {
            calls.append(.onEvent($0))
            if $0 == .ended {
                ended.fulfill()
            }
        }
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        sdk.interactor?.state = .engaged(.mock())

        XCTAssertEqual(calls, [])

        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        /// Since interactor is created only after visitor code is requested,
        /// we can be sure that if this test succeeds, interactor observer is
        /// added successfully, because observer method is called during
        /// interactor creation.

        await fulfillment(of: [ended], timeout: 1)
        XCTAssertEqual(calls, [.onEvent(.ended)])
    }

    func testOnEventWhenVideoScreenIsShownAndCallVisualizerEngagementEnds() async throws {
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
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.notificationCenter.removeObserverClosure = { _ in }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }

        let sdk = Glia(environment: gliaEnv)
        let ended = expectation(description: "Ended event")
        sdk.onEvent = {
            calls.append(.onEvent($0))
            if $0 == .ended {
                ended.fulfill()
            }
        }
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        sdk.callVisualizer.coordinator.showVideoCallViewController()
        sdk.interactor?.setEndedEngagement(.mock(source: .callVisualizer))
        sdk.interactor?.state = .ended(.byOperator)

        await fulfillment(of: [ended], timeout: 1)
        XCTAssertEqual(calls, [.onEvent(.maximized), .onEvent(.ended)])
    }

    func testConfigureThrowsErrorDuringActiveEngagement() async throws {
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

    func testConfigureSetsFeaturesFieldPassedAsParameter() async throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)
        try await sdk.configure(
            with: .mock(),
            features: .bubbleView
        )
        XCTAssertEqual(sdk.features, .bubbleView)
        try await sdk.configure(
            with: .mock(),
            features: []
        )
        XCTAssertEqual(sdk.features, [])
        try await sdk.configure(
            with: .mock(),
            features: .all
        )
        XCTAssertEqual(sdk.features, .all)
    }

    func testClearVisitorSessionThrowsErrorDuringActiveEngagement() async throws {
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
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)

        var resultingError: Error?
        let completed = expectation(description: "Clear visitor session completed")
        sdk.clearVisitorSession { result in
            defer { completed.fulfill() }
            guard case let .failure(error) = result else {
                fail("`clearVisitorSession` should fail when ongoing engegament exists.")
                return
            }
            resultingError = error
        }

        await fulfillment(of: [completed], timeout: 1)
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

    func test_maximize() async throws {
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

    func test_isConfiguredIsTrueWhenConfigurationPerformed() async throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        XCTAssertTrue(sdk.isConfigured)
        XCTAssertNotNil(sdk.interactor)
    }

    func test_isConfiguredIsTrueWhenConfigurationPerformedDuringTransferredSC() async throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        environment.coreSdk.getCurrentEngagement = { .mock(status: .transferring, capabilities: .init(text: true)) }
        let sdk = Glia(environment: environment)
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        XCTAssertTrue(sdk.isConfigured)
        XCTAssertNotNil(sdk.interactor)
    }

    func test_interactorIsInitializedAfterConfiguration() async throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        XCTAssertNotNil(sdk.interactor)
    }

    func test_isConfiguredIsFalseWhenSecondConfigureCallThrowsError() async throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.errorClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        var isFirstConfigure = true
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            if isFirstConfigure {
                isFirstConfigure = false
            } else {
                throw CoreSdkClient.GliaCoreError.mock()
            }
        }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        XCTAssertTrue(sdk.isConfigured)

        try? await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        XCTAssertFalse(sdk.isConfigured)
    }

    func test_isConfiguredIsFalseWhenConfigureWithConfigurationThrowsError() async {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.errorClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            throw CoreSdkClient.GliaCoreError.mock()
        }
        let sdk = Glia(environment: environment)
        try? await sdk.configure(
            with: .mock(),
            theme: .mock()
        )
        XCTAssertFalse(sdk.isConfigured)
    }

    @MainActor
    func test_engagementCoordinatorGetsDeallocated() async throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { 0 }
        var engCoordEnvironment = EngagementCoordinator.Environment.engagementCoordEnvironmentWithKeyWindow
        engCoordEnvironment.fileManager = .mock
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in EngagementCoordinator.mock(environment: engCoordEnvironment) }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        enum Call {
            case configureWithConfiguration
        }
        var calls: [Call] = []
        let configured = expectation(description: "Configuration completed")
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in
            calls.append(.configureWithConfiguration)
            configured.fulfill()
        }
        await fulfillment(of: [configured], timeout: 1)
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"])
        try engagementLauncher.startChat()
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            sdk.endEngagement { result in
                continuation.resume(returning: result)
            }
        }

        // Assert success and then deallocation.
        XCTAssertNoThrow(try result.get())

        // Give the runloop a chance if teardown happens on the next hop.
        await Task.yield()

        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
    }

    func test_remoteConfigIsAppliedToThemeUponConfigure() async throws {
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
            entryWidget: nil,
            isWhiteLabel: nil
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
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        let sdk = Glia(environment: environment)
        let configuration = Configuration.mock()

        try await sdk.configure(
            with: configuration,
            theme: theme,
            uiConfig: uiConfig
        )

        let primaryColorHex = sdk.theme.color.primary.toRGBAHex(alpha: false)
        let systemNegativeHex = sdk.theme.color.systemNegative.toRGBAHex(alpha: false)
        XCTAssertEqual(primaryColorHex, "#00FF00")
        XCTAssertEqual(systemNegativeHex, "#00FF00")
        XCTAssertEqual(prefixes, ["Glia", "Glia"])
        XCTAssertEqual(messages, ["Initialize Glia Widgets SDK", "Setting Unified UI Config"])
    }

    func test_hasPendingInteractionIfPendingSecureConversationExists() async throws {
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        let uuidGen = UUID.incrementing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = {
            AsyncThrowingStream { continuation in
                continuation.yield(0)
                continuation.finish()
            }
        }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = {
            AsyncThrowingStream { continuation in
                continuation.yield(true)
                continuation.finish()
            }
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }

        let sdk = Glia(environment: gliaEnv)
        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        await waitUntil { sdk.pendingInteraction?.hasPendingInteraction == true }
        XCTAssertTrue(try XCTUnwrap(sdk.pendingInteraction).hasPendingInteraction)
    }

    func test_hasPendingInteractionIfUnreadMessagesExist() async throws {
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        let uuidGen = UUID.incrementing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = {
            AsyncThrowingStream { continuation in
                continuation.yield(3)
                continuation.finish()
            }
        }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = {
            AsyncThrowingStream { continuation in
                continuation.yield(false)
                continuation.finish()
            }
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }

        let sdk = Glia(environment: gliaEnv)

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        await waitUntil { sdk.pendingInteraction?.hasPendingInteraction == true }
        XCTAssertTrue(try XCTUnwrap(sdk.pendingInteraction).hasPendingInteraction)
    }

    func test_hasPendingInteractionIfNoUnreadMessageAndPendingSecureConversationExist() async throws {
        let uuidGen = UUID.incrementing
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { AsyncThrowingStream { $0.finish() } }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _ in }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }

        let sdk = Glia(environment: gliaEnv)

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        XCTAssertFalse(try XCTUnwrap(sdk.pendingInteraction).hasPendingInteraction)
    }

    @MainActor
    func test_deauthenticateErasesInteractorState() async throws {
        let uuidGen = UUID.incrementing
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { AsyncThrowingStream { $0.finish() } }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let authentication = CoreSdkClient.Authentication(deauthenticateWithCallback: { _, callback in
            callback(.success(()))
        })
        gliaEnv.coreSdk.authentication = { _ in authentication }
        gliaEnv.coreSdk.requestEngagedOperator = { [] }
        gliaEnv.gcd.mainQueue.async = { $0() }
        gliaEnv.coreSdk.fetchSiteConfigurations = { try .mock() }
        gliaEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        gliaEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
            EngagementCoordinator.mock(
                engagementLaunching: engagementLaunching,
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        gliaEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: gliaEnv)

        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
        }

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        await sdk.interactor?.start()

        XCTAssertEqual(sdk.interactor?.state, .engaged(nil))

        try await sdk.authentication(with: .allowedDuringEngagement)
            .deauthenticate()

        XCTAssertEqual(try XCTUnwrap(sdk.interactor?.state), .none)
    }

    func test_authenticatePresentsIntermediateDialog() async throws {
        let uuidGen = UUID.incrementing
        var gliaEnv = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.secureConversations.subscribeForUnreadMessageCount = { AsyncThrowingStream { $0.finish() } }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { AsyncThrowingStream { $0.finish() } }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let authentication = CoreSdkClient.Authentication(authenticateWithIdToken: { _, _, intermediateDialogCallback, completion in
            intermediateDialogCallback({ _ in })
            completion(.success(()))
        })
        gliaEnv.coreSdk.authentication = { _ in authentication }
        gliaEnv.coreSdk.requestEngagedOperator = { [] }
        gliaEnv.gcd.mainQueue.async = { $0() }
        gliaEnv.gcd.mainQueue.asyncAfterDeadline = { _, _ in }
        gliaEnv.coreSdk.fetchSiteConfigurations = { try .mock() }
        gliaEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        gliaEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
            EngagementCoordinator.mock(
                engagementLaunching: engagementLaunching,
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }

        let sdk = Glia(environment: gliaEnv)

        var alertManagerEnv = AlertManager.Environment.failing()
        var log = CoreSdkClient.Logger.failing
        log.prefixedClosure = { _ in log }
        var messages: [String] = []
        log.infoClosure = { message, _, _, _ in
            messages.append("\(message)")
        }
        alertManagerEnv.log = log
        alertManagerEnv.uiApplication.connectionScenes = { [] }
        alertManagerEnv.uiApplication.applicationState = { .inactive }
        sdk.alertManager = .failing(environment: alertManagerEnv, viewFactory: .mock())
        sdk.alertManager.setViewControllerPresentationAnimated(false)

        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            sdk.environment.coreSdk.getCurrentEngagement = { nil }
        }

        try await sdk.configure(
            with: .mock(),
            theme: .mock()
        )

        try sdk.authentication(with: .allowedDuringEngagement)
            .authenticate(
                with: "IdToken",
                accessToken: nil
            ) { _ in }



        await waitUntil { !messages.isEmpty }
        XCTAssertEqual(messages, ["Show Push Notifications Intermediate Dialog"])
        
    }
}
