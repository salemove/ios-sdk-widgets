import SalemoveSDK
import XCTest

@testable import GliaWidgets

class GliaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test__endEngagementNotConfigured() throws {

        let sdk = Glia(environment: .failing)
        sdk.endEngagement { result in

            guard case .failure(let error) = result, let gliaError = error as? GliaError else {
                XCTFail("GliaError.sdkIsNotConfigured expected.")
                return
            }
            XCTAssertEqual(gliaError, GliaError.sdkIsNotConfigured)
        }
    }

    func test__endEngagement() throws {

        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        let sdk = Glia(environment: .failing)
        sdk.interactor = .mock()
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        sdk.endEngagement { _ in }

        XCTAssertEqual(calls, [.onEvent(.ended)])
        XCTAssertNil(sdk.rootCoordinator)
    }

    func test__deprecated_start_passes_all_arguments_to_interactor() throws {
        var gliaEnv = Glia.Environment.failing
        var fileManager = FoundationBased.FileManager.failing
        fileManager.urlsForDirectoryInDomainMask = { _, _ in
            [.mock]
        }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        gliaEnv.fileManager = fileManager
        gliaEnv.coreSdk.configureWithInteractor = { _ in }
        gliaEnv.createFileUploadListModel = { _ in .mock() }

        gliaEnv.coreSdk.configureWithConfiguration = { _, callback in
            callback?()
        }

        gliaEnv.coreSdk.queueForEngagement = { _, _, _, _, _, callback in
            callback(.mock, nil)
        }

        gliaEnv.uuid = { .mock }
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { callback in callback() }

        let expectedTheme = Theme.mock(
            colorStyle: .custom(.init()),
            fontStyle: .default,
            showsPoweredBy: true
        )
        let expectedFeatures: Features = [Features.bubbleView, .secureConversations]
        var receivedTheme: Theme?
        var receivedFeatures = Features.init()

        class MockedSceneProvider: SceneProvider {
            init () {}
            @available(iOS 13.0, *)
            func windowScene() -> UIWindowScene? {
                UIWindow().windowScene
            }
        }
        let expectedSceneProvider = MockedSceneProvider()
        var receivedSceneProvider: SceneProvider?
        gliaEnv.createRootCoordinator = { interactor, viewFactory, sceneProvider, engagementKind, features, environment in
            receivedTheme = viewFactory.theme
            receivedFeatures = features
            receivedSceneProvider = sceneProvider
            return .mock(
                interactor: interactor,
                viewFactory: viewFactory,
                sceneProvider: sceneProvider,
                environment: environment
            )
        }

        let sdk = Glia(environment: gliaEnv)
        let kind = EngagementKind.audioCall
        let site = "site"
        let configuration = Configuration(
            authorizationMethod: .siteApiKey(
                id: "siteAp1Key",
                secret: "s3cr3t"
            ),
            environment: .beta,
            site: site
        )
        let queueID = "queueID"
        let visitorContext = VisitorContext.mock()

        try sdk.start(
            kind,
            configuration: configuration,
            queueID: queueID,
            visitorContext: visitorContext,
            theme: expectedTheme,
            features: .all,
            sceneProvider: expectedSceneProvider
        )

        XCTAssertTrue(try XCTUnwrap(receivedTheme) === expectedTheme)
        XCTAssertEqual(receivedFeatures, expectedFeatures)
        XCTAssertTrue(try XCTUnwrap(receivedSceneProvider as? MockedSceneProvider) === expectedSceneProvider)
    }

    func test__messageRenderer() throws {
        let sdk = Glia(environment: .failing)
        XCTAssertNil(sdk.messageRenderer)

        let messageRendererMock = MessageRenderer.mock
        sdk.setChatMessageRenderer(messageRenderer: messageRendererMock)

        XCTAssertNotNil(sdk.messageRenderer)
    }
}
