@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SurveyViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func test_emptySurvey_extra3Large() {
        let viewController = Survey.ViewController(viewFactory: .mock(), environment: .init(notificationCenter: .mock), props: .emptyPropsMock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }

    func test_filledSurvey_extra3Large() {
        let viewController = Survey.ViewController(viewFactory: .mock(), environment: .init(notificationCenter: .mock), props: .filledPropsMock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }

    func test_emptySurveyErrorState_extra3Large() {
        let viewController = Survey.ViewController(viewFactory: .mock(), environment: .init(notificationCenter: .mock), props: .errorPropsMock())
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
    }
}
