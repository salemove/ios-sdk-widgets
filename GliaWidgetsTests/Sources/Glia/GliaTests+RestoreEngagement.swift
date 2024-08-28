@testable import GliaWidgets
import XCTest

extension GliaTests {
    func test_restoreOngoingEngagementSetsSkipLiveObservationConfirmationsToTrueAndPresentsSnackbar() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let rootCoordinator = EngagementCoordinator.mock(
            engagementKind: .chat,
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
        sdkEnv.coreSdk.createLogger = { _ in logger }
        let siteMock = try CoreSdkClient.Site.mock()
        sdkEnv.coreSdk.fetchSiteConfigurations = { callback in callback(.success(siteMock)) }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }

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
    }
}
