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
}

private extension GliaTests {
    func makeConfigurableSDK() -> Glia {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.coreSdk.localeProvider = .mock
        sdkEnv.createRootCoordinator = { _, _, _, engagementKind, _, _, _ in
            .mock(engagementKind: engagementKind, environment: .engagementCoordEnvironmentWithKeyWindow)
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
        sdkEnv.queuesMonitor = .mock()
        let window = UIWindow(frame: .zero)
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: sdkEnv)
        
        return sdk
    }
}
