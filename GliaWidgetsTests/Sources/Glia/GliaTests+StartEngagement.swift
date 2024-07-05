import GliaCoreSDK
import XCTest

@testable import GliaWidgets

extension GliaTests {
    func testStartEngagementNoLongerThrowsErrorWhenEngagementAlreadyExists() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.coreSdk.localeProvider = .mock
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
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let window = UIWindow(frame: .zero)
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: sdkEnv)

        sdk.rootCoordinator = rootCoordinator
        print("🐾", "rootCoordinator", rootCoordinator)
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }

        XCTAssertNoThrow(
            try sdk.startEngagement(
                engagementKind: .chat,
                in: ["queueID"]
            )
        )
    }

    func testStartEngagementThrowsErrorDuringActiveCallVisualizerEngagement() throws {
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { false }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        let sdk = Glia(environment: gliaEnv)
        sdk.environment.conditionalCompilation.isDebug = { true }
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
        XCTAssertThrowsError(
            try sdk.startEngagement(
                engagementKind: .chat,
                in: ["queueID"]
            )
        ) { error in
            XCTAssertEqual(error as? GliaError, GliaError.callVisualizerEngagementExists)
        }
    }

    func testStartEngagementWithNoQueueIds() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in
                .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.getCurrentEngagement = { nil }
        let sdk = Glia(environment: environment)
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }

        XCTAssertNoThrow(
            try sdk.startEngagement(
                engagementKind: .chat,
                in: []
            )
        )
    }

    func testStartCallsConfigureSdk() throws {
        enum Call { case configureWithInteractor, configureWithConfiguration }
        var calls: [Call] = []
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.remoteLoggerClosure = { .failing }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.reportDeprecatedMethodClosure = { _, _, _, _ in }
        logger.remoteLoggerClosure = { logger }
        logger.oneTimeClosure = { logger }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in
            calls.append(.configureWithInteractor)
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            calls.append(.configureWithConfiguration)
            completion(.success(()))
        }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in
            .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }
        let sdk = Glia(environment: environment)
        try sdk.start(.chat, configuration: .mock(), queueID: "queueId", theme: .mock())

        XCTAssertTrue(sdk.isConfigured)
        XCTAssertEqual(calls, [.configureWithConfiguration, .configureWithInteractor])
    }

    func testCompanyNameIsReceivedFromTheme() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock

        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { true }
        var resultingViewFactory: ViewFactory?

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementKind: .none,
                screenShareHandler: .mock,
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }

        let sdk = Glia(environment: environment)

        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(with: .mock(), theme: theme) { _ in
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])
            } catch {
                XCTFail("startEngagement unexpectedly failed with error \(error), but should succeed instead.")
            }
        }

        let configuredSdkTheme = resultingViewFactory?.theme
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, "Glia 1")
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, "Glia 2")
    }

    func testCompanyNameIsReceivedFromRemoteStrings() throws {
        var environment = Glia.Environment.failing
        var resultingViewFactory: ViewFactory?

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementKind: .none,
                screenShareHandler: .mock,
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSdk.localeProvider.getRemoteString = { _ in "Glia" }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.getCurrentEngagement = { nil }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }

        let sdk = Glia(environment: environment)

        // Even if theme is set, the remote string takes priority.
        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(with: .mock(), theme: .mock()) { _ in
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])
            } catch {
                XCTFail("startEngagement unexpectedly failed with error \(error), but should succeed instead.")
            }
        }

        let configuredSdkTheme = resultingViewFactory?.theme
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, "Glia")
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, "Glia")
    }

    func testCompanyNameIsReceivedFromConfiguration() throws {
        var environment = Glia.Environment.failing
        environment.coreSdk.createLogger = { _ in .failing }
        environment.conditionalCompilation.isDebug = { true }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }

        var resultingViewFactory: ViewFactory?

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementKind: .none,
                screenShareHandler: .mock,
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }

        let sdk = Glia(environment: environment)

        try sdk.configure(with: .mock(companyName: "Glia"), theme: .mock()) { _ in
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])
            } catch {
                XCTFail("startEngagement unexpectedly failed with error \(error), but should succeed instead.")
            }
        }

        let configuredSdkTheme = resultingViewFactory?.theme
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, "Glia")
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, "Glia")
    }

    func testCompanyNameIsReceivedFromLocalStrings() throws {
        var environment = Glia.Environment.failing
        environment.coreSdk.createLogger = { _ in .failing }
        environment.conditionalCompilation.isDebug = { true }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        var resultingViewFactory: ViewFactory?

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementKind: .none,
                screenShareHandler: .mock,
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }

        let sdk = Glia(environment: environment)

        try sdk.configure(with: .mock(), theme: .mock()) { _ in
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])
            } catch {
                XCTFail("startEngagement unexpectedly failed with error \(error), but should succeed instead.")
            }
        }

        let configuredSdkTheme = resultingViewFactory?.theme
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, "")
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, "")
    }

    func testCompanyNameIsReceivedFromThemeIfCustomLocalesIsEmpty() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }

        var resultingViewFactory: ViewFactory?

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementKind: .none,
                screenShareHandler: .mock,
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.getCurrentEngagement = { nil }

        let sdk = Glia(environment: environment)

        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(with: .mock(), theme: theme) { _ in
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])
            } catch {
                XCTFail("startEngagement unexpectedly failed with error \(error), but should succeed instead.")
            }
        }

        let configuredSdkTheme = resultingViewFactory?.theme
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, "Glia 1")
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, "Glia 2")
    }

    func testCompanyNameIsReceivedFromLocalFallbackIfCustomLocalesIsEmpty() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }

        var resultingViewFactory: ViewFactory?

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementKind: .none,
                screenShareHandler: .mock,
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSdk.getCurrentEngagement = { nil }

        let sdk = Glia(environment: environment)
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }
        try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])

        let configuredSdkTheme = resultingViewFactory?.theme
        let localFallbackCompanyName = ""
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, localFallbackCompanyName)
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, localFallbackCompanyName)
    }
}

extension EngagementCoordinator.Environment: Transformable {
    static var engagementCoordEnvironmentWithKeyWindow: Self {
        EngagementCoordinator.Environment.mock.transform {
            $0.uiApplication = .failing.transform { $0.windows = { [ .mock() ] } }
        }
    }
}
