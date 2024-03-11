import XCTest

@testable import GliaWidgets

final class GliaTestsDirectId: XCTestCase {
    /// If ongoing engagement exists, it should be restarted after autentication.
    /// To verify which should ongoing engagement restored SDK relyies on
    /// `restartedEngagementId` property in `Engagement` instance.
    func testAuthentication__shouldRestartEngagementAndFetchHistory() throws {
        enum Call { case reloadAllChild }

        var calls = [Call]()
        var authenticationResult: Result<Void, Glia.Authentication.Error>?

        var env = Glia.Environment.failing
        env.coreSdk.createLogger = { _ in .mock }
        env.gcd.mainQueue.asyncIfNeeded = { $0() }
        env.gcd.mainQueue.asyncAfterDeadline = { $1() }
        env.coreSdk.authentication = { _ in
            CoreSdkClient.Authentication(authenticateWithIdToken: { $2(.success(())) })
        }
        env.coreSDKConfigurator.configureWithInteractor = { _ in }
        env.coreSDKConfigurator.configureWithConfiguration = { $1(.success(())) }
        env.createRootCoordinator = { _, _, _, _, _, _, _ in
            var coordinatorEnv = EngagementCoordinator.Environment.mock
            coordinatorEnv.reloadAllChild = { _ in calls.append(.reloadAllChild) }
            return .mock(environment: coordinatorEnv)
        }
        env.coreSdk.localeProvider = .mock
        env.conditionalCompilation = .mock

        // Use case
        let sdk = Glia(environment: env)
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }
        try sdk.startEngagement(engagementKind: .chat, in: ["queue-id"])

        sdk.interactor?.currentEngagement = .mock(restartedFromEngagementId: "restarted-id")
        XCTAssertNotNil(sdk.rootCoordinator)

        let authentication = try sdk.authentication(with: .allowedDuringEngagement)
        authentication.authenticate(with: "", accessToken: nil) { result in
            authenticationResult = result
        }

        XCTAssertEqual(authenticationResult?.map { true }, .some(.success(true)))
        XCTAssertEqual(calls, [.reloadAllChild])
        XCTAssertNotNil(sdk.rootCoordinator)
    }

    /// If after authentication a visitor has no ongoing engagement or engagement without
    /// `restartedEngagementId` property in `Engagement` instance it should not be restored
    /// automatically.
    func testAuthentication__shouldNotSstartOngoingEngagementAfterAuthentication() throws {
        enum Call { case reloadAllChild }

        var calls = [Call]()
        var authenticationResult: Result<Void, Glia.Authentication.Error>?

        var env = Glia.Environment.failing
        env.coreSdk.createLogger = { _ in .mock }
        env.gcd.mainQueue.asyncIfNeeded = { $0() }
        env.gcd.mainQueue.asyncAfterDeadline = { $1() }
        env.coreSdk.authentication = { _ in
            CoreSdkClient.Authentication(authenticateWithIdToken: { $2(.success(())) })
        }
        env.coreSDKConfigurator.configureWithInteractor = { _ in }
        env.coreSDKConfigurator.configureWithConfiguration = { $1(.success(())) }
        env.createRootCoordinator = { _, _, _, _, _, _, _ in
            var coordinatorEnv = EngagementCoordinator.Environment.mock
            coordinatorEnv.reloadAllChild = { _ in calls.append(.reloadAllChild) }
            return .mock(environment: coordinatorEnv)
        }
        env.coreSdk.localeProvider = .mock
        env.conditionalCompilation = .mock

        // Use case
        let sdk = Glia(environment: env)
        try sdk.configure(with: .mock(), theme: .mock()) { _ in }
        try sdk.startEngagement(engagementKind: .chat, in: ["queue-id"])

        sdk.interactor?.currentEngagement = .mock()
        XCTAssertNotNil(sdk.rootCoordinator)

        let authentication = try sdk.authentication(with: .allowedDuringEngagement)
        authentication.authenticate(with: "", accessToken: nil) { result in
            authenticationResult = result
        }

        XCTAssertEqual(authenticationResult?.map { true }, .some(.success(true)))
        XCTAssertEqual(calls, [])
        XCTAssertNil(sdk.rootCoordinator)
    }
}

extension Glia.Authentication.Error: Equatable {
    public static func == (lhs: Glia.Authentication.Error, rhs: Glia.Authentication.Error) -> Bool {
        lhs.reason == rhs.reason
    }
}
