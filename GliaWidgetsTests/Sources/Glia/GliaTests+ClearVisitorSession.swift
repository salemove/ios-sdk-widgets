import XCTest

@testable import GliaWidgets

extension GliaTests {
    func testClearVisitorSessionThrowsErrorWhileQueued() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.interactor?.state = .enqueued(.mock, .chat)

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession { receivedResult = $0 }

        guard case let .failure(error) = try XCTUnwrap(receivedResult) else {
            XCTFail("`clearVisitorSession` should fail while queued.")
            return
        }
        XCTAssertEqual(error as? GliaError, .clearingVisitorSessionDuringEngagementIsNotAllowed)
        XCTAssertEqual(sdk.interactor?.state, .enqueued(.mock, .chat))
    }

    func testClearVisitorSessionCallsCoreWithoutInteraction() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        var events: [GliaEvent] = []
        sdk.onEvent = { events.append($0) }
        var clearSessionCalls: [Bool] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.environment.coreSdk.clearSession = { stopPushNotifications, completion in
            clearSessionCalls.append(stopPushNotifications)
            completion()
        }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession { receivedResult = $0 }

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertEqual(clearSessionCalls, [false])
        XCTAssertEqual(events, [])
    }

    func testClearVisitorSessionPassesShouldStopPushNotificationsThroughToCoreSdk() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        var clearSessionCalls: [Bool] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.environment.coreSdk.clearSession = { stopPushNotifications, completion in
            clearSessionCalls.append(stopPushNotifications)
            completion()
        }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession(shouldStopPushNotifications: true) { receivedResult = $0 }

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertEqual(clearSessionCalls, [true])
    }

    func testClearVisitorSessionEndsEngagementAndClosesUI() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        var events: [GliaEvent] = []
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        sdk.onEvent = { events.append($0) }
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
        var clearSessionCalls: [Bool] = []
        sdk.environment.coreSdk.clearSession = { stopPushNotifications, completion in
            clearSessionCalls.append(stopPushNotifications)
            // Core drops the engagement before completing.
            sdk.environment.coreSdk.getCurrentEngagement = { nil }
            completion()
        }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession(shouldEndEngagementIfPresent: true) { receivedResult = $0 }

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertEqual(clearSessionCalls, [false])
        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
        XCTAssertEqual(events.filter { $0 == .ended }, [.ended])
    }

    func testClearVisitorSessionCancelsQueueAndClosesUI() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        var events: [GliaEvent] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        sdk.interactor?.state = .enqueued(.mock, .chat)
        sdk.onEvent = { events.append($0) }
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        sdk.environment.coreSdk.clearSession = { _, completion in completion() }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession(shouldEndEngagementIfPresent: true) { receivedResult = $0 }

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
        XCTAssertEqual(events.filter { $0 == .ended }, [.ended])
    }

    func testClearVisitorSessionEndsCallVisualizerEngagement() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        var events: [GliaEvent] = []
        let ended = expectation(description: "Ended event")
        sdk.onEvent = {
            events.append($0)
            if $0 == .ended {
                ended.fulfill()
            }
        }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
        sdk.environment.coreSdk.clearSession = { _, completion in
            sdk.environment.coreSdk.getCurrentEngagement = { nil }
            completion()
        }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession(shouldEndEngagementIfPresent: true) { receivedResult = $0 }

        wait(for: [ended], timeout: 1)
        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertEqual(events, [.ended])
    }

    func testClearVisitorSessionSucceedsWhenSdkIsNotConfigured() throws {
        var environment = Self.makeClearVisitorSessionEnvironment()
        var clearSessionCalls: [Bool] = []
        environment.coreSdk.getCurrentEngagement = { .mock() }
        environment.coreSdk.clearSession = { stopPushNotifications, completion in
            clearSessionCalls.append(stopPushNotifications)
            completion()
        }
        let sdk = Glia(environment: environment)

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession(shouldEndEngagementIfPresent: true) { receivedResult = $0 }

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertEqual(clearSessionCalls, [false])
    }

    func testClearVisitorSessionCompletesWhenGliaIsDeallocated() throws {
        var environment = Self.makeClearVisitorSessionEnvironment()
        var pendingCoreCompletion: (() -> Void)?
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.clearSession = { _, completion in
            pendingCoreCompletion = completion
        }
        var sdk: Glia? = Glia(environment: environment)
        weak var weakSdk = sdk

        var receivedResult: Result<Void, Error>?
        sdk?.clearVisitorSession { receivedResult = $0 }
        sdk = nil
        XCTAssertNil(weakSdk)
        try XCTUnwrap(pendingCoreCompletion)()

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
    }

    func testDeauthenticateClosesEngagementUI() throws {
        let sdk = try makeConfiguredSdkForClearVisitorSession()
        let authentication = CoreSdkClient.Authentication(deauthenticateWithCallback: { _, callback in
            callback(.success(()))
        })
        sdk.environment.coreSdk.authentication = { _ in authentication }
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)

        try sdk.authentication(with: .allowedDuringEngagement).deauthenticate { _ in }

        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
    }
}

private extension GliaTests {
    static func makeClearVisitorSessionEnvironment() -> Glia.Environment {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }
        environment.gcd.mainQueue.async = { $0() }
        environment.gcd.mainQueue.asyncIfNeeded = { $0() }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        return environment
    }

    func makeConfiguredSdkForClearVisitorSession() throws -> Glia {
        var environment = Self.makeClearVisitorSessionEnvironment()
        environment.coreSDKConfigurator.configureWithConfiguration = { _, callback in
            callback(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.callVisualizerPresenter = .init(presenter: { nil })
        var engCoordEnvironment = EngagementCoordinator.Environment.engagementCoordEnvironmentWithKeyWindow
        engCoordEnvironment.fileManager = .mock
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in
            EngagementCoordinator.mock(environment: engCoordEnvironment)
        }
        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }
        return sdk
    }
}
