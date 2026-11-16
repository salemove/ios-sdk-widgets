import XCTest

@testable import GliaWidgets

extension GliaTests {
    @MainActor
    func testClearVisitorDataCallsCoreWithoutInteraction() async throws {
        let sdk = try await makeConfiguredSdkForClearVisitorData()
        var events: [GliaEvent] = []
        sdk.onEvent = { events.append($0) }
        var clearSessionCalls: [Bool] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.environment.coreSdk.clearSession = { stopPushNotifications in
            clearSessionCalls.append(stopPushNotifications)
        }

        sdk.clearVisitorData()

        XCTAssertEqual(clearSessionCalls, [true])
        XCTAssertEqual(events, [])
    }

    @MainActor
    func testClearVisitorDataEndsEngagementAndClosesUI() async throws {
        let sdk = try await makeConfiguredSdkForClearVisitorData()
        var events: [GliaEvent] = []
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        sdk.onEvent = { events.append($0) }
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
        var clearSessionCalls: [Bool] = []
        sdk.environment.coreSdk.clearSession = { stopPushNotifications in
            clearSessionCalls.append(stopPushNotifications)
            // Core drops the engagement while clearing.
            sdk.environment.coreSdk.getCurrentEngagement = { nil }
        }

        sdk.clearVisitorData()

        XCTAssertEqual(clearSessionCalls, [true])
        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
        XCTAssertEqual(events.filter { $0 == .ended }, [.ended])
    }

    @MainActor
    func testClearVisitorDataCancelsQueueAndClosesUI() async throws {
        let sdk = try await makeConfiguredSdkForClearVisitorData()
        var events: [GliaEvent] = []
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        sdk.interactor?.state = .enqueued(.mock, .chat)
        sdk.onEvent = { events.append($0) }
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)
        sdk.environment.coreSdk.clearSession = { _ in }

        sdk.clearVisitorData()

        XCTAssertNil(sdk.rootCoordinator)
        XCTAssertNil(rootCoordinator)
        XCTAssertEqual(sdk.interactor?.state, InteractorState.none)
        XCTAssertEqual(events.filter { $0 == .ended }, [.ended])
    }

    @MainActor
    func testClearVisitorDataEndsCallVisualizerEngagement() async throws {
        let sdk = try await makeConfiguredSdkForClearVisitorData()
        var events: [GliaEvent] = []
        let ended = expectation(description: "Ended event")
        sdk.onEvent = {
            events.append($0)
            if $0 == .ended {
                ended.fulfill()
            }
        }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
        sdk.environment.coreSdk.clearSession = { _ in
            sdk.environment.coreSdk.getCurrentEngagement = { nil }
        }

        sdk.clearVisitorData()

        await fulfillment(of: [ended], timeout: 1)
        XCTAssertEqual(events, [.ended])
    }

    @MainActor
    func testClearVisitorDataCallsCoreWhenSdkIsNotConfigured() async throws {
        var environment = Self.makeClearVisitorDataEnvironment()
        var clearSessionCalls: [Bool] = []
        environment.coreSdk.getCurrentEngagement = { .mock() }
        environment.coreSdk.clearSession = { stopPushNotifications in
            clearSessionCalls.append(stopPushNotifications)
        }
        let sdk = Glia(environment: environment)

        sdk.clearVisitorData()

        XCTAssertEqual(clearSessionCalls, [true])
    }

    @MainActor
    func testClearVisitorDataClearsCoreSessionBeforeClosingUI() async throws {
        let sdk = try await makeConfiguredSdkForClearVisitorData()
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        var wasUIOpenWhenClearingCoreSession: Bool?
        sdk.environment.coreSdk.clearSession = { _ in
            wasUIOpenWhenClearingCoreSession = sdk.rootCoordinator != nil
        }

        sdk.clearVisitorData()

        XCTAssertEqual(wasUIOpenWhenClearingCoreSession, true)
        XCTAssertNil(sdk.rootCoordinator)
    }

    @MainActor
    func testDeauthenticateClosesEngagementUI() async throws {
        let sdk = try await makeConfiguredSdkForClearVisitorData()
        let authentication = CoreSdkClient.Authentication(deauthenticateWithCallback: { _, callback in
            callback(.success(()))
        })
        sdk.environment.coreSdk.authentication = { _ in authentication }
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        try sdk.getEngagementLauncher(queueIds: ["mockedQueueId"]).startChat()
        weak var rootCoordinator = sdk.rootCoordinator
        XCTAssertNotNil(rootCoordinator)

        try await sdk.authentication(with: .allowedDuringEngagement).deauthenticate()

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
        environment.coreSdk.secureConversations.pendingSecureConversationStatusStream = {
            AsyncThrowingStream { $0.finish() }
        }
        return environment
    }

    func makeConfiguredSdkForClearVisitorData() async throws -> Glia {
        var environment = Self.makeClearVisitorDataEnvironment()
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { 0 }
        environment.callVisualizerPresenter = .init(presenter: { nil })
        var engCoordEnvironment = EngagementCoordinator.Environment.engagementCoordEnvironmentWithKeyWindow
        engCoordEnvironment.fileManager = .mock
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in
            EngagementCoordinator.mock(environment: engCoordEnvironment)
        }
        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try await sdk.configure(with: .mock(), theme: .mock())
        return sdk
    }
}
