import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class SurveyViewControllerVoiceOverTests: SnapshotTestCase {
    func test_emptySurvey() {
        let viewController = Survey.ViewController(viewFactory: .mock(), props: .emptyPropsMock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_filledSurvey() {
        let viewController = Survey.ViewController(viewFactory: .mock(), props: .filledPropsMock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }

    func test_emptySurveyErrorState() {
        let viewController = Survey.ViewController(viewFactory: .mock(), props: .errorPropsMock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage,
            named: nameForDevice()
        )
    }
}
