@testable import GliaWidgets
import XCTest

class EngagementCoordinatorSurveyTests: XCTestCase {
    func test_surveyCompletesWithUnexpectedError() {
        let coreSdkClient = CoreSdkClient.failing
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, callback in
                callback(.failure(.mock()))
            },
            media: .init(audio: .none, video: .oneWay),
            actionOnEnd: .showSurvey
        )
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdkClient, queuesMonitor: .mock(), gcd: .failing, log: .failing))
        interactor.setEndedEngagement(engagement)
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
            engagementLaunching: .direct(kind: .audioCall),
            screenShareHandler: .mock,
            features: [],
            environment: engagementCoordinatorEnv
        )
        coordinator.end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(messages, ["Show Unexpected error Dialog"])
    }
}
