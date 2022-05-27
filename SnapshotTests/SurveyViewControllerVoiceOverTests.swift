import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class SurveyViewControllerVoiceOverTests: SnapshotTestCase {
    func test_emptySurvey() {
        let viewController = Survey.ViewController(props: .emptyPropsMock(), theme: Theme.mock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }

    func test_filledSurvey() {
        let viewController = Survey.ViewController(props: .filledPropsMock(), theme: Theme.mock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }

    func test_emptySurveyErrorState() {
        let viewController = Survey.ViewController(props: .errorPropsMock(), theme: Theme.mock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }
}
