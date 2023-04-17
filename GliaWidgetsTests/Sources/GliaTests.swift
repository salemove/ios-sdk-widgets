import SalemoveSDK
import XCTest

@testable import GliaWidgets

final class GliaTests: XCTestCase {
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
        gliaEnv.uiDevice.isProximityMonitoringEnabled = { _ in }
        gliaEnv.uiScreen.brightness = { 0 }
        gliaEnv.uiApplication.isIdleTimerDisabled = { _ in }
        gliaEnv.notificationCenter.removeObserverClosure = { _ in }
        gliaEnv.notificationCenter.removeObserverWithNameAndObject = { _, _, _ in }
        gliaEnv.notificationCenter.addObserverClosure = { _, _, _, _ in }
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
        let expectedFeatures: Features = [Features.bubbleView]
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
        gliaEnv.createRootCoordinator = { interactor, viewFactory, sceneProvider, engagementKind, screenShareHandler, features, environment in
            receivedTheme = viewFactory.theme
            receivedFeatures = features
            receivedSceneProvider = sceneProvider
            return .mock(
                interactor: interactor,
                viewFactory: viewFactory,
                sceneProvider: sceneProvider,
                screenShareHandler: screenShareHandler,
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

    func testStartEngagementThrowsErrorWhenEngagementAlreadyExists() throws {
        let sdk = Glia(environment: .failing)
        sdk.rootCoordinator = .mock(engagementKind: .chat, screenShareHandler: .mock)
        try sdk.configure(with: .mock(), queueId: "queueID")

        XCTAssertThrowsError(try sdk.startEngagement(engagementKind: .chat)) { error in
            XCTAssertEqual(error as? GliaError, GliaError.engagementExists)
        }
    }

    func testStartEngagementThrowsErrorDuringActiveCallVisualizerEngagement() throws {
        var gliaEnv = Glia.Environment.failing
        gliaEnv.coreSdk.getCurrentEngagement = {
            Engagement(id: "", engagedOperator: nil, source: .callVisualizer, fetchSurvey: { _, _ in })
        }
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(with: .mock(), queueId: "queueID")

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

    func test__messageRenderer() throws {
        let sdk = Glia(environment: .failing)
        XCTAssertNil(sdk.messageRenderer)

        let messageRendererMock = MessageRenderer.mock
        sdk.setChatMessageRenderer(messageRenderer: messageRendererMock)

        XCTAssertNotNil(sdk.messageRenderer)
    }

    func testOnEventWhenCallVisualizerEngagementStarts() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { callback in callback() }
        gliaEnv.coreSdk.getCurrentEngagement = {
            .init(id: "", engagedOperator: nil, source: .callVisualizer, fetchSurvey: { _, _ in })
        }
        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            queueId: "queueId"
        )

        sdk.interactor?.state = .engaged(nil)

        XCTAssertEqual(calls, [.onEvent(.started)])
    }

    func testOnEventWhenCallVisualizerEngagementEnds() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { callback in callback() }
        gliaEnv.coreSdk.getCurrentEngagement = {
            .init(id: "", engagedOperator: nil, source: .callVisualizer, fetchSurvey: { _, _ in })
        }
        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            queueId: "queueId"
        )
        
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(calls, [.onEvent(.ended)])
    }

    func testOnEventWhenScreenSharingScreenIsShownAndCallVisualizerEngagementEnds() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { callback in callback() }
        gliaEnv.coreSdk.getCurrentEngagement = {
            .init(id: "", engagedOperator: nil, source: .callVisualizer, fetchSurvey: { _, _ in })
        }
        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            queueId: "queueId"
        )

        sdk.callVisualizer.coordinator.showEndScreenSharingViewController()
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(calls, [.onEvent(.minimized), .onEvent(.ended)])
    }

    func testOnEventWhenVideoScreenIsShownAndCallVisualizerEngagementEnds() throws {
        enum Call: Equatable {
            case onEvent(GliaEvent)
        }
        var calls = [Call]()

        var gliaEnv = Glia.Environment.failing
        gliaEnv.uuid = { .mock }
        gliaEnv.uiApplication.windows = { [] }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { callback in callback() }
        gliaEnv.notificationCenter.addObserverClosure = { _, _, _, _ in }
        gliaEnv.coreSdk.getCurrentEngagement = {
            .init(id: "", engagedOperator: nil, source: .callVisualizer, fetchSurvey: { _, _ in })
        }
        let sdk = Glia(environment: gliaEnv)
        sdk.onEvent = {
            calls.append(.onEvent($0))
        }
        try sdk.configure(
            with: .mock(),
            queueId: "queueId"
        )

        sdk.callVisualizer.coordinator.showVideoCallViewController()
        sdk.interactor?.state = .ended(.byOperator)

        XCTAssertEqual(calls, [.onEvent(.maximized), .onEvent(.minimized), .onEvent(.ended)])
    }
}
