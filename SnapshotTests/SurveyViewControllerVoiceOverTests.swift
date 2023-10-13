import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SurveyViewControllerVoiceOverTests: SnapshotTestCase {
    func test_emptySurvey() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .emptyPropsMock()
        )
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_emptySurveyWithDefaultValue() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .emptyPropsMockWithDefaultValue()
        )
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_filledSurvey() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .filledPropsMock()
        )
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_emptySurveyErrorState() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .errorPropsMock()
        )
        viewController.assertSnapshot(as: .accessibilityImage)
    }
}
