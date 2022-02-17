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
        visitorContext: CoreSdkClient.VisitorContext(type: .page, url: "www.glia.com")
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
}
