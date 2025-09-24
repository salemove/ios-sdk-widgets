@testable import GliaWidgets
import XCTest

extension GliaTests {
    func test_startSecureMessageWhenSecureMessagePushReceivedBeforeConfigure() throws {
        let sdk = makeConfigurableSDK()

        sdk.environment.coreSdk.pushNotifications.actions.secureMessageAction()?("queue_id")

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.engagementRestorationState = .restored

        XCTAssertEqual(sdk.interactor?.queueIds, ["queue_id"])
        XCTAssertEqual(sdk.engagement, .messaging(.chatTranscript))
    }

    func test_startSecureMessageWhenSecureMessagePushReceivedAfterConfigure() throws {
        let sdk = makeConfigurableSDK()

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.engagementRestorationState = .restored

        sdk.environment.coreSdk.pushNotifications.actions.secureMessageAction()?("queue_id")

        XCTAssertEqual(sdk.interactor?.queueIds, ["queue_id"])
        XCTAssertEqual(sdk.engagement, .messaging(.chatTranscript))
    }

    func test_startSecureMessageWhenSecureMessagePushReceivedForUnauthenticatedUser() throws {
        let sdk = makeConfigurableSDK(isAuthenticated: false)

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }

        sdk.engagementRestorationState = .restored

        sdk.environment.coreSdk.pushNotifications.actions.secureMessageAction()?("queue_id")

        XCTAssertEqual(sdk.interactor?.queueIds, ["queue_id"])
        XCTAssertEqual(sdk.engagement, .none)
    }
}

private extension GliaTests {
    func makeConfigurableSDK(isAuthenticated: Bool = true) -> Glia {
        var sdkEnv = Glia.Environment.mock
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.coreSdk.localeProvider = .mock
        
        var mockSCMessagePushAction: ((String?) -> Void)?
        sdkEnv.coreSdk.pushNotifications.actions = .init(
            setSecureMessageAction: { mockSCMessagePushAction = $0 },
            secureMessageAction: { mockSCMessagePushAction }
        )
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
        sdkEnv.isAuthenticated = { isAuthenticated }
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
