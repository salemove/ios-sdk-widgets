import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class SurveyViewControllerVoiceOverTests: SnapshotTestCase {
    func test_emptySurvey() {
        let viewController = Survey.ViewController(viewFactory: .mock(), props: .emptyPropsMock())
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_filledSurvey() {
        let viewController = Survey.ViewController(viewFactory: .mock(), props: .filledPropsMock())
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_emptySurveyErrorState() {
        let viewController = Survey.ViewController(viewFactory: .mock(), props: .errorPropsMock())
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }
}
