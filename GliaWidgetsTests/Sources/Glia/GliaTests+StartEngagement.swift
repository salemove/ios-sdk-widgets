import GliaCoreSDK
import XCTest

@testable import GliaWidgets

extension GliaTests {
    override class func tearDown() {
        Glia.sharedInstance.stringProviding = nil
    }

    func testStartEngagementThrowsErrorWhenEngagementAlreadyExists() throws {
        var sdkEnv = Glia.Environment.failing
        sdkEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        let sdk = Glia(environment: sdkEnv)
        sdk.rootCoordinator = .mock(engagementKind: .chat, screenShareHandler: .mock)
        try sdk.configure(with: .mock())

        XCTAssertThrowsError(
            try sdk.startEngagement(
                engagementKind: .chat,
                in: ["queueID"]
            )
        ) { error in
            XCTAssertEqual(error as? GliaError, GliaError.engagementExists)
        }
    }

    func testStartEngagementThrowsErrorDuringActiveCallVisualizerEngagement() throws {
        let sdk = Glia(environment: .failing)
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        try sdk.configure(with: .mock()) {}
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

    func testStartEngagementThrowsErrorWhenSdkHasNoQueueIds() {
        let sdk = Glia(environment: .failing)

        XCTAssertThrowsError(
            try sdk.startEngagement(
                engagementKind: .chat,
                in: []
            )
        ) { error in
            XCTAssertEqual(error as? GliaError, GliaError.startingEngagementWithNoQueueIdsIsNotAllowed)
        }
    }

    func testStartCallsConfigureSdk() throws {
        enum Call { case configureWithInteractor, configureWithConfiguration }
        var calls: [Call] = []
        var environment = Glia.Environment.failing
        environment.coreSDKConfigurator.configureWithInteractor = { _ in
            calls.append(.configureWithInteractor)
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            calls.append(.configureWithConfiguration)
            completion(.success(()))
        }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }
        environment.createRootCoordinator = { _, _, _, _, _, _, _ in
            .mock()
        }
        let sdk = Glia(environment: environment)

        try sdk.start(.chat, configuration: .mock(), queueID: "queueId", visitorContext: nil)

        XCTAssertTrue(sdk.isConfigured)
        XCTAssertEqual(calls, [.configureWithConfiguration, .configureWithInteractor])
    }

    func testCompanyNameIsReceivedFromTheme() throws {
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
                environment: .failing
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
                environment: .failing
            )
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "Glia" }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.getCurrentEngagement = { nil }

        let sdk = Glia(environment: environment)

        // Even if theme is set, the remote string takes priority.
        let theme = Theme()
        theme.call.connect.queue.firstText = "Glia 1"
        theme.chat.connect.queue.firstText = "Glia 2"

        try sdk.configure(with: .mock()) {
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"], theme: theme)
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
                environment: .failing
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }

        let sdk = Glia(environment: environment)

        try sdk.configure(with: .mock(companyName: "Glia")) {
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
                environment: .failing
            )
        }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.localeProvider.getRemoteString = { _ in nil }

        let sdk = Glia(environment: environment)

        try sdk.configure(with: .mock()) {
            do {
                try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])
            } catch {
                XCTFail("startEngagement unexpectedly failed with error \(error), but should succeed instead.")
            }
        }

        let configuredSdkTheme = resultingViewFactory?.theme
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, "Company Name")
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, "Company Name")
    }

    func testCompanyNameIsReceivedFromThemeIfCustomLocalesIsEmpty() throws {
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
                environment: .failing
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
                environment: .failing
            )
        }

        environment.coreSdk.localeProvider.getRemoteString = { _ in "" }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            // Simulating what happens in the Widgets when the configuration gets done
            Glia.sharedInstance.stringProviding = StringProviding(
                getRemoteString: environment.coreSdk.localeProvider.getRemoteString
            )
            completion(.success(()))
        }
        environment.coreSdk.getCurrentEngagement = { nil }

        let sdk = Glia(environment: environment)
        try sdk.configure(with: .mock(), completion: {})
        try sdk.startEngagement(engagementKind: .chat, in: ["queueId"])

        let configuredSdkTheme = resultingViewFactory?.theme
        let localFallbackCompanyName = "Company Name"
        XCTAssertEqual(configuredSdkTheme?.call.connect.queue.firstText, localFallbackCompanyName)
        XCTAssertEqual(configuredSdkTheme?.chat.connect.queue.firstText, localFallbackCompanyName)
    }
}
