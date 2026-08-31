@testable import GliaWidgets
import XCTest

class EngagementCoordinatorSurveyTests: XCTestCase {
    func test_endDoesNotFetchSurveyWhenQueueingFailsDuringLiveEngagement() {
        var surveyWasFetched = false
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyWasFetched = true
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.queueForEngagement = { _, _, completion in
            completion(.failure(.mock()))
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.state = .enqueueing(.chat)
        interactor.enqueueForEngagement(
            engagementKind: .chat,
            replaceExisting: false,
            success: { XCTFail("Expected queueing to fail") },
            failure: { _ in }
        )
        let coordinator = makeCoordinator(interactor: interactor)

        coordinator.end(surveyPresentation: .presentSurvey)

        XCTAssertFalse(surveyWasFetched)
    }

    func test_enqueueingStateInvalidatesPreviousUnconsumedConfirmedEnd() {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.getCurrentEngagement = { engagement }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.end(with: .operatorHungUp)
        interactor.onEngagementChanged(nil)

        interactor.state = .enqueueing(.chat)

        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

        XCTAssertEqual(surveyFetchCount, 0)
    }

    func test_coreEndMakesSurveyEligibleBeforeNotifyingObservers() {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.getCurrentEngagement = { engagement }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        let coordinator = makeCoordinator(interactor: interactor)
        interactor.onEngagementChanged(engagement)
        interactor.addObserver(self) { event in
            guard case .stateChanged(.ended(.byOperator)) = event else { return }
            coordinator.end(surveyPresentation: .presentSurvey)
        }

        interactor.end(with: .operatorHungUp)

        XCTAssertEqual(surveyFetchCount, 1)
    }

    func test_endFetchesSurveyAfterVisitorEndsEngagement() {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var interactor: Interactor!
        var coordinator: EngagementCoordinator!
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = { completion in
            completion(true, nil)
        }
        interactor = makeInteractor(coreSdk: coreSdkClient)
        coordinator = makeCoordinator(interactor: interactor)
        interactor.onEngagementChanged(engagement)
        interactor.state = .engaged(.mock())
        interactor.addObserver(self) { event in
            guard case .stateChanged(.ended(.byVisitor)) = event else { return }
            coordinator.end(surveyPresentation: .presentSurvey)
        }

        interactor.endSession { result in
            if case let .failure(error) = result {
                XCTFail("Expected engagement to end successfully, got \(error)")
            }
        }
        interactor.onEngagementChanged(nil)

        XCTAssertEqual(surveyFetchCount, 1)
    }

    func test_visitorEndCompletionDoesNotConfirmNewerEngagement() {
        var endingSurveyFetchCount = 0
        var newerSurveyFetchCount = 0
        let endingEngagement = CoreSdkClient.Engagement.mock(
            id: "ending-engagement",
            fetchSurvey: { _, _ in
                endingSurveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        let newerEngagement = CoreSdkClient.Engagement.mock(
            id: "newer-engagement",
            fetchSurvey: { _, _ in
                newerSurveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var endCompletion: CoreSdkClient.SuccessBlock?
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = { completion in
            endCompletion = completion
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        var endResult: Result<Void, Error>?
        interactor.onEngagementChanged(endingEngagement)
        interactor.state = .engaged(.mock())
        interactor.endSession { endResult = $0 }
        interactor.state = .enqueueing(.chat)
        interactor.onEngagementChanged(newerEngagement)
        let newerOperator = CoreSdkClient.Operator.mock(id: "newer-operator")
        interactor.state = .engaged(newerOperator)

        endCompletion?(true, nil)

        let coordinator = makeCoordinator(interactor: interactor)
        coordinator.end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(endingSurveyFetchCount, 0)
        XCTAssertEqual(newerSurveyFetchCount, 0)
        XCTAssertEqual(interactor.currentEngagement?.id, newerEngagement.id)
        XCTAssertEqual(interactor.state, .engaged(newerOperator))
        assertSuccess(endResult)
    }

    func test_delayedVisitorEndCompletionDoesNotOutliveNewQueueLifecycle() {
        var surveyFetchCount = 0
        let endingEngagement = CoreSdkClient.Engagement.mock(
            id: "ending-engagement",
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var endCompletion: CoreSdkClient.SuccessBlock?
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = { completion in
            endCompletion = completion
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        var endResult: Result<Void, Error>?
        interactor.onEngagementChanged(endingEngagement)
        interactor.state = .engaged(.mock())
        interactor.endSession { endResult = $0 }
        interactor.onEngagementChanged(nil)
        interactor.state = .enqueueing(.chat)

        endCompletion?(true, nil)

        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(surveyFetchCount, 0)
        XCTAssertEqual(interactor.state, .enqueueing(.chat))
        assertSuccess(endResult)
    }

    func test_staleVisitorEndFailureDoesNotCancelNewerEndRequest() {
        var endingSurveyFetchCount = 0
        var newerSurveyFetchCount = 0
        let endingEngagement = CoreSdkClient.Engagement.mock(
            id: "ending-engagement",
            fetchSurvey: { _, _ in
                endingSurveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        let newerEngagement = CoreSdkClient.Engagement.mock(
            id: "newer-engagement",
            fetchSurvey: { _, _ in
                newerSurveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var endCompletions: [CoreSdkClient.SuccessBlock] = []
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = { completion in
            endCompletions.append(completion)
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(endingEngagement)
        interactor.state = .engaged(.mock())
        interactor.endSession { _ in }
        interactor.state = .enqueueing(.chat)
        interactor.onEngagementChanged(newerEngagement)
        interactor.state = .engaged(.mock())
        interactor.endSession { _ in }

        XCTAssertEqual(endCompletions.count, 2)
        endCompletions[0](false, .mock())
        endCompletions[1](true, nil)
        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

        XCTAssertEqual(endingSurveyFetchCount, 0)
        XCTAssertEqual(newerSurveyFetchCount, 1)
    }

    func test_endFetchesSurveyWhenCoreClearsEngagementBeforeVisitorEndCompletion() {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            id: "ending-engagement",
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var endCompletion: CoreSdkClient.SuccessBlock?
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = { completion in
            endCompletion = completion
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.state = .engaged(.mock())
        interactor.endSession { result in
            if case let .failure(error) = result {
                XCTFail("Expected engagement to end successfully, got \(error)")
            }
        }

        interactor.onEngagementChanged(nil)
        endCompletion?(true, nil)
        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

        XCTAssertEqual(surveyFetchCount, 1)
    }

    func test_coreEndUsesCurrentCoreEngagementInsteadOfCachedEngagement() {
        let reasons: [CoreSdkClient.EngagementEndingReason] = [.visitorHungUp, .error]

        for reason in reasons {
            var cachedSurveyFetchCount = 0
            var currentSurveyFetchCount = 0
            let cachedEngagement = CoreSdkClient.Engagement.mock(
                id: "cached-engagement",
                fetchSurvey: { _, _ in
                    cachedSurveyFetchCount += 1
                },
                actionOnEnd: .showSurvey
            )
            let currentEngagement = CoreSdkClient.Engagement.mock(
                id: "current-engagement",
                fetchSurvey: { _, _ in
                    currentSurveyFetchCount += 1
                },
                actionOnEnd: .showSurvey
            )
            var coreSdkClient = CoreSdkClient.mock
            coreSdkClient.getCurrentEngagement = { currentEngagement }
            let interactor = makeInteractor(coreSdk: coreSdkClient)
            interactor.onEngagementChanged(cachedEngagement)

            interactor.end(with: reason)
            makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

            XCTAssertEqual(cachedSurveyFetchCount, 0, "Core end reason: \(reason)")
            XCTAssertEqual(currentSurveyFetchCount, 1, "Core end reason: \(reason)")
        }
    }

    func test_coreEndReasonsRemainEligibleForSurvey() {
        let reasons: [CoreSdkClient.EngagementEndingReason] = [
            .visitorHungUp,
            .operatorHungUp,
            .followUp,
            .error
        ]

        for reason in reasons {
            var surveyFetchCount = 0
            let engagement = CoreSdkClient.Engagement.mock(
                fetchSurvey: { _, _ in
                    surveyFetchCount += 1
                },
                actionOnEnd: .showSurvey
            )
            var coreSdkClient = CoreSdkClient.mock
            coreSdkClient.getCurrentEngagement = { engagement }
            let interactor = makeInteractor(coreSdk: coreSdkClient)
            interactor.onEngagementChanged(engagement)
            interactor.end(with: reason)

            makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

            XCTAssertEqual(surveyFetchCount, 1, "Core end reason: \(reason)")
        }
    }

    func test_doNotPresentSurveyConsumesConfirmedEnd() {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.getCurrentEngagement = { engagement }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.end(with: .operatorHungUp)

        makeCoordinator(interactor: interactor).end(surveyPresentation: .doNotPresentSurvey)
        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

        XCTAssertEqual(surveyFetchCount, 0)
    }

    func test_failedVisitorEndDoesNotMakeSurveyEligible() {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = { completion in
            completion(false, .mock())
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.state = .engaged(.mock())
        interactor.endSession { result in
            guard case .failure = result else {
                XCTFail("Expected ending the engagement to fail")
                return
            }
        }

        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

        XCTAssertEqual(surveyFetchCount, 0)
    }

    func test_surveyCompletesWithUnexpectedError() {
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, callback in
                callback(.failure(.mock()))
            },
            media: .init(audio: .none, video: .oneWay),
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.failing
        coreSdkClient.getCurrentEngagement = { engagement }
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdkClient, queuesMonitor: .mock(), gcd: .failing, log: .failing))
        interactor.onEngagementChanged(engagement)
        interactor.end(with: .visitorHungUp)
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
            features: [],
            engagementRestorationState: { .none },
            environment: engagementCoordinatorEnv
        )
        coordinator.end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(messages, ["Show Unexpected error Dialog"])
    }
}

private extension EngagementCoordinatorSurveyTests {
    func makeInteractor(coreSdk: CoreSdkClient) -> Interactor {
        Interactor.mock(
            environment: .init(
                coreSdk: coreSdk,
                queuesMonitor: .mock(),
                gcd: .mock,
                log: .mock
            )
        )
    }

    func makeCoordinator(interactor: Interactor) -> EngagementCoordinator {
        EngagementCoordinator(
            interactor: interactor,
            viewFactory: .mock(),
            sceneProvider: nil,
            engagementLaunching: .direct(kind: .chat),
            features: [],
            engagementRestorationState: { .none },
            environment: .mock()
        )
    }

    func assertSuccess(
        _ result: Result<Void, Error>?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let result else {
            XCTFail("Expected stale end request to complete", file: file, line: line)
            return
        }
        guard case .success = result else {
            XCTFail("Expected successful Core end to remain successful", file: file, line: line)
            return
        }
    }
}
