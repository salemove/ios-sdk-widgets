@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SurveyViewControllerLayoutTests: SnapshotTestCase {
    func test_emptySurvey() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .mock(),
            props: .emptyPropsMock()
        )
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    func test_filledSurvey() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .mock(),
            props: .filledPropsMock()
        )
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }

    func test_emptySurveyErrorState() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .mock(),
            props: .errorPropsMock()
        )
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }
}
