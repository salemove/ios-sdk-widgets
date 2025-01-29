@testable import GliaWidgets
import GliaCoreSDK
import XCTest

extension GliaTests {
    func test_skipLiveObservationConfirmations() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let rootCoordinator = EngagementCoordinator.mock(
            engagementLaunching: .direct(kind: .chat),
            screenShareHandler: .mock,
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
        sdkEnv.coreSdk.fetchSiteConfigurations = { callback in callback(.success(siteMock)) }
        sdkEnv.coreSdk.pendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.getSecureUnreadMessageCount = { $0(.success(0)) }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        sdkEnv.coreSdk.subscribeForUnreadSCMessageCount = { _ in nil }
        sdkEnv.coreSdk.observePendingSecureConversationStatus = { _ in nil }
        sdkEnv.coreSdk.unsubscribeFromPendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.unsubscribeFromUnreadCount = { _ in }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        enum Call {
            case snackBarPresent
        }

        var calls: [Call] = []
        sdkEnv.snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.snackBarPresent)
        }

        sdkEnv.coreSdk.listQueues = { callback in callback([], nil) }
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
        sdk.restoreOngoingEngagement(
            configuration: .mock(),
            currentEngagement: .mock(),
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

    func test_restoreOngoingSecureConversationEngagement() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.createRootCoordinator = { _, _, _, engagementLaunching, _, _, _ in
            EngagementCoordinator.mock(
                engagementLaunching: engagementLaunching,
                screenShareHandler: .mock,
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
        sdkEnv.coreSdk.fetchSiteConfigurations = { callback in callback(.success(siteMock)) }
        sdkEnv.coreSdk.pendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.getSecureUnreadMessageCount = { $0(.success(0)) }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let uuidGen = UUID.incrementing
        sdkEnv.coreSdk.subscribeForUnreadSCMessageCount = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.observePendingSecureConversationStatus = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.unsubscribeFromPendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.unsubscribeFromUnreadCount = { _ in }
        sdkEnv.gcd.mainQueue.async = { $0() }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        enum Call {
            case snackBarPresent
        }

        var calls: [Call] = []
        sdkEnv.snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.snackBarPresent)
        }

        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock() }
        sdk.stringProvidingPhase = .configured { _ in
            return ""
        }
        guard let interactor = sdk.interactor else {
            XCTFail("Interactor missing")
            return
        }
        interactor.state = .engaged(.mock())

        XCTAssertNotNil(sdk.rootCoordinator?.gliaViewController)
        XCTAssertEqual(calls, [.snackBarPresent])
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
        sdkEnv.coreSdk.fetchSiteConfigurations = { callback in callback(.success(siteMock)) }
        sdkEnv.coreSdk.pendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.getSecureUnreadMessageCount = { $0(.success(0)) }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let uuidGen = UUID.incrementing
        sdkEnv.coreSdk.subscribeForUnreadSCMessageCount = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.observePendingSecureConversationStatus = { _ in uuidGen().uuidString }
        sdkEnv.coreSdk.unsubscribeFromPendingSecureConversationStatus = { _ in }
        sdkEnv.coreSdk.unsubscribeFromUnreadCount = { _ in }
        sdkEnv.gcd.mainQueue.async = { $0() }

        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }

        sdkEnv.snackBar.present = { _, _, _, _, _, _, _ in
            XCTFail("SDK should not present snackBar")
        }

        let sdk = Glia(environment: sdkEnv)
        try sdk.configure(with: .mock(), features: .all) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = {
            .mock(status: .transferring, capabilities: .init(text: true))
        }
        sdk.stringProvidingPhase = .configured { _ in
            return ""
        }
        guard let interactor = sdk.interactor else {
            XCTFail("Interactor missing")
            return
        }
        interactor.state = .engaged(.mock())

        XCTAssertNil(sdk.rootCoordinator?.gliaViewController)
    }
}
