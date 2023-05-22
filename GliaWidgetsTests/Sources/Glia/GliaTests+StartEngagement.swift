import GliaCoreSDK
import XCTest

@testable import GliaWidgets

extension GliaTests {
    func testStartEngagementThrowsErrorWhenEngagementAlreadyExists() throws {
        let sdk = Glia(environment: .failing)
        sdk.rootCoordinator = .mock(engagementKind: .chat, screenShareHandler: .mock)
        try sdk.configure(with: .mock(), queueId: "queueID")

        XCTAssertThrowsError(try sdk.startEngagement(engagementKind: .chat)) { error in
            XCTAssertEqual(error as? GliaError, GliaError.engagementExists)
        }
    }

    func testStartEngagementThrowsErrorDuringActiveCallVisualizerEngagement() throws {
        let sdk = Glia(environment: .failing)
        try sdk.configure(with: .mock(), queueId: "queueID")

        sdk.environment.coreSdk.getCurrentEngagement = { .mock(source: .callVisualizer) }

        XCTAssertThrowsError(try sdk.startEngagement(engagementKind: .chat)) { error in
            XCTAssertEqual(error as? GliaError, GliaError.callVisualizerEngagementExists)
        }
    }

    func testStartEngagementThrowsErrorWhenSdkIsNotConfigured() {
        let sdk = Glia(environment: .failing)

        XCTAssertThrowsError(try sdk.startEngagement(engagementKind: .chat)) { error in
            XCTAssertEqual(error as? GliaError, GliaError.sdkIsNotConfigured)
        }
    }

    func testStartCallsConfigureSdk() throws {
        enum Call { case configureWithInteractor, configureWithConfiguration }
        var calls: [Call] = []
        var environment = Glia.Environment.failing
        environment.coreSdk.configureWithInteractor = { _ in
            calls.append(.configureWithInteractor)
        }
        environment.coreSdk.configureWithConfiguration = { _, _ in
            calls.append(.configureWithConfiguration)
        }
        let sdk = Glia(environment: environment)

        try sdk.start(.chat, configuration: .mock(), queueID: "queueId", visitorContext: nil)

        let interactor = try XCTUnwrap(sdk.interactor)
        XCTAssertTrue(interactor.isConfigurationPerformed)
        XCTAssertEqual(calls, [.configureWithInteractor, .configureWithConfiguration])
    }
}
