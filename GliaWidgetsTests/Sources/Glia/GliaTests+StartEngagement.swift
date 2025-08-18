import XCTest

@testable import GliaWidgets

extension GliaTests {
    func testStartEngagementNoLongerThrowsErrorWhenEngagementAlreadyExists() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdkEnv.coreSdk.localeProvider = .mock
        let rootCoordinator = EngagementCoordinator.mock(
            engagementLaunching: .direct(kind: .chat),
            environment: .engagementCoordEnvironmentWithKeyWindow
        )
        sdkEnv.createRootCoordinator = { _, _, _, _, _, _ in
            rootCoordinator
        }
        sdkEnv.print.printClosure = { _, _, _ in }
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        sdkEnv.coreSdk.createLogger = { _ in logger }
        sdkEnv.coreSdk.secureConversations.pendingStatus = { _ in }
        sdkEnv.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        sdkEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        sdkEnv.conditionalCompilation.isDebug = { true }
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let window = UIWindow(frame: .zero)
        window.makeKeyAndVisible()
        sdkEnv.uiApplication.windows = { [window] }
        let sdk = Glia(environment: sdkEnv)
        sdk.queuesMonitor = .mock()
        sdk.rootCoordinator = rootCoordinator
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])

        XCTAssertNoThrow(try engagementLauncher.startChat())
    }

    func testStartEngagementShowsSnackBarDuringActiveCallVisualizerEngagement() throws {
        enum Call {
            case presentSnackBar
        }
        var calls: [Call] = []
        var snackBarMessage: String?
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { false }
        gliaEnv.coreSdk.createLogger = { _ in logger }
        gliaEnv.coreSdk.localeProvider.getRemoteString = { _ in nil }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        sdk.queuesMonitor = .mock()
        sdk.environment.conditionalCompilation.isDebug = { true }
        sdk.environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let window = UIWindow(frame: .zero)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        sdk.environment.uiApplication.windows = { [window] }
        sdk.environment.snackBar.present = { message, _, _, _, _, _, _ in
            snackBarMessage = message
            calls.append(.presentSnackBar)
        }

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueID"])
        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }
 
        try engagementLauncher.startChat()

        XCTAssertEqual(calls, [.presentSnackBar])
        XCTAssertEqual(snackBarMessage, Localization.EntryWidget.CallVisualizer.description)
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
        environment.createRootCoordinator = { _, _, _, _, _, _ in
                .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: [])

        XCTAssertNoThrow(
            try engagementLauncher.startChat()
        )
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

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(
            with: .mock(),
            theme: theme
        ) { _ in
            do {
                let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
                try engagementLauncher.startChat()
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

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
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
        environment.coreSdk.secureConversations.pendingStatus = { _ in }
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        // Even if theme is set, the remote string takes priority.
        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in
            do {
                let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
                try engagementLauncher.startChat()
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

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(companyName: "Glia"),
            theme: .mock()
        ) { _ in
            do {
                let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
                try engagementLauncher.startChat()
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

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
                features: [],
                environment: .engagementCoordEnvironmentWithKeyWindow
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in
            do {
                let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
                try engagementLauncher.startChat()
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

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
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
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(
            with: .mock(),
            theme: theme
        ) { _ in
            do {
                let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
                try engagementLauncher.startChat()
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

        environment.createRootCoordinator = { _, viewFactory, _, _, _, _ in
            resultingViewFactory = viewFactory

            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: viewFactory,
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
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
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startChat()

        let configuredSdkTheme = resultingViewFactory?.theme
        let localFallbackCompanyName = ""
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, localFallbackCompanyName)
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, localFallbackCompanyName)
    }

    func testStartEngagementChangesEngagementKindIfPendingSecureConversationExists() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }

        let engagementKind = EngagementKind.chat
        var engagementLaunching: EngagementCoordinator.EngagementLaunching = .direct(kind: engagementKind)

        environment.createRootCoordinator = { _, _, _, launching, _, _ in
            engagementLaunching = launching
            return .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSdk.secureConversations.pendingStatus = { $0(.success(true)) }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let uuIdGen = UUID.incrementing
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.secureConversations.subscribeForUnreadMessageCount = {
            $0(.success(0))
            return uuIdGen().uuidString
        }
        environment.coreSdk.secureConversations.observePendingStatus = {
            $0(.success(true))
            return uuIdGen().uuidString
        }
        environment.coreSdk.secureConversations.unsubscribeFromPendingStatus = { _ in }
        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startChat()

        XCTAssertEqual(engagementLaunching.currentKind, .messaging(.chatTranscript))
        XCTAssertEqual(engagementLaunching.initialKind, engagementKind)
    }

    func testStartEngagementDoesNotChangeEngagementKindIfNoPendingSecureConversationExists() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }

        let engagementKind = EngagementKind.chat
        var engagementLaunching: EngagementCoordinator.EngagementLaunching = .direct(kind: engagementKind)

        environment.createRootCoordinator = { _, _, _, launching, _, _ in
            engagementLaunching = launching
            return .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSdk.secureConversations.pendingStatus = { $0(.success(false)) }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startChat()

        XCTAssertEqual(engagementLaunching.currentKind, engagementKind)
    }

    func testStartEngagementWithMessagingIfPendingSecureConversationExists() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }
        environment.isAuthenticated = { true }

        let engagementKind = EngagementKind.messaging(.welcome)
        var engagementLaunching: EngagementCoordinator.EngagementLaunching = .direct(kind: engagementKind)

        environment.createRootCoordinator = { _, _, _, launching, _, _ in
            engagementLaunching = launching
            return .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSdk.secureConversations.pendingStatus = { $0(.success(true)) }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let uuIdGen = UUID.incrementing
        environment.coreSdk.getCurrentEngagement = { nil }
        environment.coreSdk.secureConversations.subscribeForUnreadMessageCount = { callback in
            callback(.success(0))
            return uuIdGen().uuidString
        }
        environment.coreSdk.secureConversations.observePendingStatus = { callback in
            callback(.success(true))
            return uuIdGen().uuidString
        }
        environment.coreSdk.secureConversations.unsubscribeFromPendingStatus = { _ in }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startSecureMessaging()

        XCTAssertEqual(engagementLaunching.currentKind, .messaging(.chatTranscript))
    }

    func testEngagementParamsDoNotLeakThroughEngagements() throws {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        environment.coreSdk.createLogger = { _ in logger }
        environment.print = .mock
        environment.conditionalCompilation.isDebug = { true }
        environment.gcd.mainQueue.async = { $0() }

        var engagementLaunching: EngagementCoordinator.EngagementLaunching = .direct(kind: .audioCall)

        environment.createRootCoordinator = { _, _, _, launching, _, _ in
            engagementLaunching = launching
            return .mock(environment: .engagementCoordEnvironmentWithKeyWindow)
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSdk.secureConversations.pendingStatus = { $0(.success(false)) }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSdk.secureConversations.getUnreadMessageCount = { $0(.success(0)) }
        environment.coreSdk.secureConversations.subscribeForUnreadMessageCount = { _ in nil }
        environment.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        environment.coreSdk.fetchSiteConfigurations = { _ in }

        let sdk = Glia(environment: environment)
        sdk.queuesMonitor = .mock()
        let window = UIWindow(frame: .zero)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        sdk.environment.uiApplication.windows = { [window] }
        sdk.environment.snackBar.present = { _, _, _, _, _, _, _ in }
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { _ in }
        // Mock ongoing Audio engagement
        let engagement = CoreSdkClient.Engagement.mock(media: .init(audio: .twoWay, video: nil))
        sdk.environment.coreSdk.getCurrentEngagement = { engagement }

        let engagementLauncher = try sdk.getEngagementLauncher(queueIds: ["queueId"])
        try engagementLauncher.startChat()
        XCTAssertEqual(engagementLaunching.currentKind, .audioCall)

        // End audio engagement
        sdk.environment.coreSdk.getCurrentEngagement = { nil }
        sdk.interactor?.end(with: .operatorHungUp)

        try engagementLauncher.startChat()

        XCTAssertEqual(engagementLaunching.currentKind, .chat)
    }
}

extension EngagementCoordinator.Environment: Transformable {
    static var engagementCoordEnvironmentWithKeyWindow: Self {
        EngagementCoordinator.Environment.mock.transform {
            $0.uiApplication = .failing.transform {
                $0.windows = { [ .mock() ] }
                $0.preferredContentSizeCategory = { .unspecified }
            }
        }
    }
}
