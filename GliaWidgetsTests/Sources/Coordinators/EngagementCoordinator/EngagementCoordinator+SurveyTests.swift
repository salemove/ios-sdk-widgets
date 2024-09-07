@testable import GliaWidgets
import XCTest

class EngagementCoordinatorSurveyTests: XCTestCase {
    func test_surveyCompletesWithUnexpectedError() {
        let coreSdkClient = CoreSdkClient.failing
        let engagement = CoreSdkClient.Engagement(
            id: "", 
            engagedOperator: nil,
            source: .coreEngagement,
            fetchSurvey: { _, callback in
                callback(.failure(.mock()))
            },
            mediaStreams: .init(audio: .none, video: .oneWay)
        )
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdkClient, gcd: .failing, log: .failing))
        interactor.currentEngagement = engagement
        var alertManagerEnv = AlertManager.Environment.failing()
        var log = CoreSdkClient.Logger.failing
        log.prefixedClosure = { _ in log }
        var messages: [String] = []
        log.infoClosure = { message, _, _, _ in
            messages.append("\(message)")
        }
        alertManagerEnv.log = log
        alertManagerEnv.uiApplication.connectionScenes = { [] }
        var engagementCoordinatorEnv = EngagementCoordinator.Environment.failing
        engagementCoordinatorEnv.alertManager = .failing(environment: alertManagerEnv, viewFactory: .mock())
        engagementCoordinatorEnv.alertManager.setViewControllerPresentationAnimated(false)
        engagementCoordinatorEnv.uiApplication.applicationState = { .inactive }
        let coordinator = EngagementCoordinator(
            interactor: interactor,
            viewFactory: ViewFactory.mock(),
            sceneProvider: nil,
            engagementKind: .audioCall,
            screenShareHandler: .mock,
            features: [],
            environment: engagementCoordinatorEnv
        )
        coordinator.end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(messages, ["Show Unexpected error Dialog"])
    }

    func test_surveyCompletesWithErrorAndRetries() throws {
        let coreSdkClient = CoreSdkClient.failing
        var expectedErrors = [CoreSdkClient.GliaCoreError.mock()]
        let survey = try CoreSdkClient.Survey.mock()

        let engagement = CoreSdkClient.Engagement(
            id: "", engagedOperator: nil,
            source: .coreEngagement,
            fetchSurvey: { _, callback in
                if let err = expectedErrors.first {
                    expectedErrors.removeFirst()
                    callback(.failure(err))
                } else {
                     callback(.success(survey))
                }
            },
            mediaStreams: .init(audio: .none, video: .oneWay)
        )
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdkClient, gcd: .failing, log: .failing))
        interactor.currentEngagement = engagement
        var log = CoreSdkClient.Logger.failing
        log.prefixedClosure = { _ in log }
        var messages: [String] = []
        log.infoClosure = { message, _, _, _ in
            messages.append("\(message)")
        }
        var engagementCoordinatorEnv = EngagementCoordinator.Environment.failing
        engagementCoordinatorEnv.log = log
        engagementCoordinatorEnv.uiApplication.applicationState = { .background }
        engagementCoordinatorEnv.notificationCenter.addObserverForNameWithObjectWithQueueUsingBlock = { _, _, _, callback in
            callback(Notification(name: UIApplication.willEnterForegroundNotification))
            return NSObject()
        }
        engagementCoordinatorEnv.notificationCenter.removeObserverClosure = { _ in }
        engagementCoordinatorEnv.notificationCenter.addObserverClosure = { _, _, _, _ in }
        engagementCoordinatorEnv.uiApplication.windows = { [UIWindow.mock()] }
        let coordinator = EngagementCoordinator(
            interactor: interactor,
            viewFactory: ViewFactory.mock(),
            sceneProvider: nil,
            engagementKind: .audioCall,
            screenShareHandler: .mock,
            features: [],
            environment: engagementCoordinatorEnv
        )
        // Set dummy observer to avoid early out during notification center callback invocation.
        coordinator.applicationStateObserver = NSObject()
        coordinator.end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(messages, ["Survey loaded", "Create Survey screen"])
    }
}
