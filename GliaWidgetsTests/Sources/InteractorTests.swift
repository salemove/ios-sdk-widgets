import XCTest

@testable import GliaWidgets

class InteractorTests: XCTestCase {

    let mock = (
        queueId: "i'm-queue-identifier",
        config: try! CoreSdkClient.Salemove.Configuration(
            siteId: "mocked-id",
            region: .us,
            authorizingMethod: .appToken("mocked-app-token")
        ),
        visitorContext: CoreSdkClient.VisitorContext.mock
    )

    var interactor: Interactor!

    func test__enqueueForEngagement() throws {

        enum Call {
            case configureWithConfiguration, configureWithInteractor, queueForEngagement
        }
        var coreSdkCalls = [Call]()

        var coreSdk = CoreSdkClient.failing
        coreSdk.configureWithConfiguration = { _, completion in
            coreSdkCalls.append(.configureWithConfiguration)
            completion?()
        }
        coreSdk.configureWithInteractor = { _ in
            coreSdkCalls.append(.configureWithInteractor)
        }
        coreSdk.queueForEngagement = { _, _, _, _, _, _ in
            coreSdkCalls.append(.queueForEngagement)
        }
        interactor = .init(
            with: mock.config,
            queueID: mock.queueId,
            visitorContext: mock.visitorContext,
            environment: .init(coreSdk: coreSdk)
        )

        interactor.enqueueForEngagement(mediaType: .text) {} failure: {
            XCTFail($0.reason)
        }

        XCTAssertEqual(coreSdkCalls, [
            .configureWithInteractor,
            .configureWithConfiguration,
            .queueForEngagement
        ])
    }

    func test__isConfigurationPerformedIsInitiallyFalse() {
        XCTAssertFalse(Interactor.mock(environment: .failing).isConfigurationPerformed)
    }

    func test__isConfigurationPerformedBecomesTrue() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { _, _ in }
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.withConfiguration {}
        XCTAssertTrue(interactor.isConfigurationPerformed)
    }

    func test__configureWithConfigurationPerformedOnce() {
        enum Call {
            case configureWithConfiguration
        }
        var calls: [Call] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { _, _ in
            calls.append(.configureWithConfiguration)
        }
        let interactor = Interactor.mock(environment: interactorEnv)
        for _ in 0 ..< 1000 {
            interactor.withConfiguration {}
        }
        XCTAssertEqual(calls, [.configureWithConfiguration])
    }

    func test_withConfigurationInvokesCompletionForFirstAndNextCalls() {
        enum Callback {
            case withConfiguration
        }
        var callbacks: [Callback] = []
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.configureWithConfiguration = { $1?() }
        let interactor = Interactor.mock(environment: interactorEnv)
        for _ in 0 ..< 3 {
            interactor.withConfiguration {
                callbacks.append(.withConfiguration)
            }
        }

        XCTAssertEqual(callbacks, [.withConfiguration, .withConfiguration, .withConfiguration])
    }
}
