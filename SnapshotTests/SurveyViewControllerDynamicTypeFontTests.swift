@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SurveyViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func test_emptySurvey_extra3Large() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock, log: .mock),
            props: .emptyPropsMock()
        )
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_filledSurvey_extra3Large() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock, log: .mock),
            props: .filledPropsMock()
        )
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_emptySurveyErrorState_extra3Large() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock, log: .mock),
            props: .errorPropsMock()
        )
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
