@testable import GliaWidgets
import XCTest

final class SurveyViewControllerPropsTests: XCTestCase {
    @MainActor
    func test_validSubmitClosesAndSubmitsOnceWhenTappedTwice() async throws {
        let survey: CoreSdkClient.Survey = try .mock(id: "survey-id")
        var submittedIds: [String] = []
        var closeCount = 0
        let props = Survey.ViewController.Props.live(
            sdkSurvey: survey,
            engagementId: "engagement-id",
            submitSurveyAnswer: { _, surveyId, engagementId in
                submittedIds.append("\(surveyId.rawValue)/\(engagementId)")
            },
            cancel: {},
            endEditing: {},
            updateProps: { _ in },
            completion: { closeCount += 1 }
        )

        await props.submit(props)
        await props.submit(props)

        XCTAssertEqual(submittedIds, ["survey-id/engagement-id"])
        XCTAssertEqual(closeCount, 1)
    }

    @MainActor
    func test_invalidSubmitNeitherClosesNorSubmits() async throws {
        var submitCount = 0
        var closeCount = 0
        var updatedProps: Survey.ViewController.Props?
        var props = Survey.ViewController.Props.live(
            sdkSurvey: try .mock(),
            engagementId: "engagement-id",
            submitSurveyAnswer: { _, _, _ in submitCount += 1 },
            cancel: {},
            endEditing: {},
            updateProps: { updatedProps = $0 },
            completion: { closeCount += 1 }
        )
        props.questionsProps = [Survey.ViewController.Props.makeScalePropsMock()]

        await props.submit(props)

        XCTAssertEqual(submitCount, 0)
        XCTAssertEqual(closeCount, 0)
        XCTAssertEqual(updatedProps?.questionsProps.map(\.showValidationError), [true])
    }

    @MainActor
    func test_validSubmitAfterInvalidSubmitClosesAndSubmits() async throws {
        var submitCount = 0
        var closeCount = 0
        let props = Survey.ViewController.Props.live(
            sdkSurvey: try .mock(),
            engagementId: "engagement-id",
            submitSurveyAnswer: { _, _, _ in submitCount += 1 },
            cancel: {},
            endEditing: {},
            updateProps: { _ in },
            completion: { closeCount += 1 }
        )
        var invalidProps = props
        invalidProps.questionsProps = [Survey.ViewController.Props.makeScalePropsMock()]

        await props.submit(invalidProps)
        await props.submit(props)

        XCTAssertEqual(submitCount, 1)
        XCTAssertEqual(closeCount, 1)
    }
}
