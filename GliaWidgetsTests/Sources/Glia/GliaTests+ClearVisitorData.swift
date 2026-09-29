import XCTest

@testable import GliaWidgets

extension GliaTests {
    func testClearVisitorDataCallsCoreWithoutInteraction() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
        var events: [GliaEvent] = []
        sdk.onEvent = { events.append($0) }
        var clearSessionCalls: [Bool] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.environment.coreSdk.clearSession = { stopPushNotifications, completion in
            clearSessionCalls.append(stopPushNotifications)
            completion()
        }

        sdk.clearVisitorData()

        XCTAssertEqual(clearSessionCalls, [true])
        XCTAssertEqual(events, [])
    }

    func testClearVisitorDataEndsEngagementAndClosesUI() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
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

        sdk.clearVisitorData()

        XCTAssertEqual(clearSessionCalls, [true])
        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
        XCTAssertEqual(events.filter { $0 == .ended }, [.ended])
    }

    func testClearVisitorDataCancelsQueueAndClosesUI() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
        var events: [GliaEvent] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        sdk.interactor?.state = .enqueued(.mock, .chat)
        sdk.onEvent = { events.append($0) }
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        sdk.environment.coreSdk.clearSession = { _, completion in completion() }

        sdk.clearVisitorData()

        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
        XCTAssertEqual(events.filter { $0 == .ended }, [.ended])
    }

    func testClearVisitorDataEndsCallVisualizerEngagement() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
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

        sdk.clearVisitorData()

        wait(for: [ended], timeout: 1)
        XCTAssertEqual(events, [.ended])
    }

    func testClearVisitorDataClosesUIOnMainQueueAfterCoreCompletes() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        var pendingCoreCompletion: (() -> Void)?
        sdk.environment.coreSdk.clearSession = { _, completion in pendingCoreCompletion = completion }
        var pendingMainQueueWork: [() -> Void] = []
        sdk.environment.gcd.mainQueue.asyncIfNeeded = { pendingMainQueueWork.append($0) }

        sdk.clearVisitorData()
        XCTAssertNotNil(sdk.rootCoordinator)

        // Core completes off the main queue: nothing is closed until the main queue runs the work.
        try XCTUnwrap(pendingCoreCompletion)()
        XCTAssertNotNil(sdk.rootCoordinator)
        XCTAssertEqual(pendingMainQueueWork.count, 1)

        pendingMainQueueWork.forEach { $0() }
        XCTAssertNil(sdk.rootCoordinator)
    }

    func testClearVisitorDataCallsCoreWhenSdkIsNotConfigured() throws {
        var environment = Self.makeClearVisitorDataEnvironment()
        var clearSessionCalls: [Bool] = []
        environment.coreSdk.getCurrentEngagement = { .mock() }
        environment.coreSdk.clearSession = { stopPushNotifications, completion in
            clearSessionCalls.append(stopPushNotifications)
            completion()
        }
        let sdk = Glia(environment: environment)

        sdk.clearVisitorData()

        XCTAssertEqual(clearSessionCalls, [true])
    }

    func testClearVisitorDataDoesNotRetainGlia() throws {
        var environment = Self.makeClearVisitorDataEnvironment()
        var pendingCoreCompletion: (() -> Void)?
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.clearSession = { _, completion in
            pendingCoreCompletion = completion
        }
        var sdk: Glia? = Glia(environment: environment)
        weak var weakSdk = sdk

        sdk?.clearVisitorData()
        sdk = nil

        XCTAssertNil(weakSdk)
        try XCTUnwrap(pendingCoreCompletion)()
    }

    @available(*, deprecated)
    func testDeprecatedClearVisitorSessionRefusesDuringEngagement() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
        sdk.environment.coreSdk.getCurrentEngagement = { .mock() }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession { receivedResult = $0 }

        guard case let .failure(error) = try XCTUnwrap(receivedResult) else {
            XCTFail("`clearVisitorSession` should fail during an engagement.")
            return
        }
        XCTAssertEqual(error as? GliaError, .clearingVisitorSessionDuringEngagementIsNotAllowed)
    }

    @available(*, deprecated)
    func testDeprecatedClearVisitorSessionCallsLegacyCoreClearSession() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
        var legacyClearSessionCalls = 0
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.environment.coreSdk.legacyClearSession = { legacyClearSessionCalls += 1 }

        var receivedResult: Result<Void, Error>?
        sdk.clearVisitorSession { receivedResult = $0 }

        XCTAssertNoThrow(try XCTUnwrap(receivedResult).get())
        XCTAssertEqual(legacyClearSessionCalls, 1)
    }

    func testDeauthenticateClosesEngagementUI() throws {
        let sdk = try makeConfiguredSdkForClearVisitorData()
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
    static func makeClearVisitorDataEnvironment() -> Glia.Environment {
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

    func makeConfiguredSdkForClearVisitorData() throws -> Glia {
        var environment = Self.makeClearVisitorDataEnvironment()
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
