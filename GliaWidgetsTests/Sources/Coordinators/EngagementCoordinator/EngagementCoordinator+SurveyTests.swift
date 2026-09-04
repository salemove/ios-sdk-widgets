@testable import GliaWidgets
import XCTest

@MainActor
class EngagementCoordinatorSurveyTests: XCTestCase {
    func test_endDoesNotFetchSurveyWhenQueueingFailsDuringLiveEngagement() async {
        var surveyWasFetched = false
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyWasFetched = true
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.queueForEngagement = { _, _ in
            throw CoreSdkClient.SalemoveError.mock()
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.state = .enqueueing(.chat)
        do {
            try await interactor.enqueueForEngagement(
                engagementKind: .chat,
                replaceExisting: false
            )
            XCTFail("Expected queueing to fail")
        } catch {}
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

    func test_endFetchesSurveyAfterVisitorEndsEngagement() async throws {
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
        coreSdkClient.endEngagement = { true }
        interactor = makeInteractor(coreSdk: coreSdkClient)
        coordinator = makeCoordinator(interactor: interactor)
        interactor.onEngagementChanged(engagement)
        interactor.state = .engaged(.mock())
        interactor.addObserver(self) { event in
            guard case .stateChanged(.ended(.byVisitor)) = event else { return }
            coordinator.end(surveyPresentation: .presentSurvey)
        }

        try await interactor.endSession()
        interactor.onEngagementChanged(nil)

        XCTAssertEqual(surveyFetchCount, 1)
    }

    func test_visitorEndCompletionDoesNotConfirmNewerEngagement() async throws {
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
        var endContinuation: CheckedContinuation<Bool, Error>?
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = {
            try await withCheckedThrowingContinuation { continuation in
                endContinuation = continuation
            }
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(endingEngagement)
        interactor.state = .engaged(.mock())
        let endTask = Task { @MainActor in try await interactor.endSession() }
        await waitUntil { endContinuation != nil }
        let continuation = try XCTUnwrap(endContinuation)
        interactor.state = .enqueueing(.chat)
        interactor.onEngagementChanged(newerEngagement)
        let newerOperator = CoreSdkClient.Operator.mock(id: "newer-operator")
        interactor.state = .engaged(newerOperator)

        continuation.resume(returning: true)
        let endResult = await endTask.result

        let coordinator = makeCoordinator(interactor: interactor)
        coordinator.end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(endingSurveyFetchCount, 0)
        XCTAssertEqual(newerSurveyFetchCount, 0)
        XCTAssertEqual(interactor.currentEngagement?.id, newerEngagement.id)
        XCTAssertEqual(interactor.state, .engaged(newerOperator))
        assertSuccess(endResult)
    }

    func test_delayedVisitorEndCompletionDoesNotOutliveNewQueueLifecycle() async throws {
        var surveyFetchCount = 0
        let endingEngagement = CoreSdkClient.Engagement.mock(
            id: "ending-engagement",
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var endContinuation: CheckedContinuation<Bool, Error>?
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = {
            try await withCheckedThrowingContinuation { continuation in
                endContinuation = continuation
            }
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(endingEngagement)
        interactor.state = .engaged(.mock())
        let endTask = Task { @MainActor in try await interactor.endSession() }
        await waitUntil { endContinuation != nil }
        let continuation = try XCTUnwrap(endContinuation)
        interactor.onEngagementChanged(nil)
        interactor.state = .enqueueing(.chat)

        continuation.resume(returning: true)
        let endResult = await endTask.result

        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)
        XCTAssertEqual(surveyFetchCount, 0)
        XCTAssertEqual(interactor.state, .enqueueing(.chat))
        assertSuccess(endResult)
    }

    func test_staleVisitorEndFailureDoesNotCancelNewerEndRequest() async throws {
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
        var endContinuations: [CheckedContinuation<Bool, Error>] = []
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = {
            try await withCheckedThrowingContinuation { continuation in
                endContinuations.append(continuation)
            }
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(endingEngagement)
        interactor.state = .engaged(.mock())
        let firstEndTask = Task { @MainActor in try await interactor.endSession() }
        await waitUntil { endContinuations.count == 1 }
        interactor.state = .enqueueing(.chat)
        interactor.onEngagementChanged(newerEngagement)
        interactor.state = .engaged(.mock())
        let secondEndTask = Task { @MainActor in try await interactor.endSession() }
        await waitUntil { endContinuations.count == 2 }
        let firstContinuation = try XCTUnwrap(endContinuations.first)
        let secondContinuation = try XCTUnwrap(endContinuations.dropFirst().first)

        firstContinuation.resume(throwing: CoreSdkClient.SalemoveError.mock())
        secondContinuation.resume(returning: true)
        if case .success = await firstEndTask.result {
            XCTFail("Expected the stale end request to fail")
        }
        assertSuccess(await secondEndTask.result)
        makeCoordinator(interactor: interactor).end(surveyPresentation: .presentSurvey)

        XCTAssertEqual(endingSurveyFetchCount, 0)
        XCTAssertEqual(newerSurveyFetchCount, 1)
    }

    func test_endFetchesSurveyWhenCoreClearsEngagementBeforeVisitorEndCompletion() async throws {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            id: "ending-engagement",
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var endContinuation: CheckedContinuation<Bool, Error>?
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = {
            try await withCheckedThrowingContinuation { continuation in
                endContinuation = continuation
            }
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.state = .engaged(.mock())
        let endTask = Task { @MainActor in try await interactor.endSession() }
        await waitUntil { endContinuation != nil }
        let continuation = try XCTUnwrap(endContinuation)

        interactor.onEngagementChanged(nil)
        continuation.resume(returning: true)
        assertSuccess(await endTask.result)
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

    func test_failedVisitorEndDoesNotMakeSurveyEligible() async {
        var surveyFetchCount = 0
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, _ in
                surveyFetchCount += 1
            },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.endEngagement = {
            throw CoreSdkClient.SalemoveError.mock()
        }
        let interactor = makeInteractor(coreSdk: coreSdkClient)
        interactor.onEngagementChanged(engagement)
        interactor.state = .engaged(.mock())
        do {
            try await interactor.endSession()
            XCTFail("Expected ending the engagement to fail")
        } catch {}

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
        let interactor = Interactor.mock(
            environment: .init(
                coreSdk: coreSdkClient,
                queuesMonitor: .mock(),
                gcd: .mock,
                log: .failing
            )
        )
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
        _ result: Result<Void, Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .success = result else {
            XCTFail("Expected successful Core end to remain successful", file: file, line: line)
            return
        }
    }
}
