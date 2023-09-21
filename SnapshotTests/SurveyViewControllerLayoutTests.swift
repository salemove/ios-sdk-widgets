@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SurveyViewControllerLayoutTests: SnapshotTestCase {
    func test_emptySurvey() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .emptyPropsMock()
        )
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_filledSurvey() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .filledPropsMock()
        )
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_emptySurveyErrorState() {
        let viewController = Survey.ViewController(
            viewFactory: .mock(),
            environment: .init(notificationCenter: .mock),
            props: .errorPropsMock()
        )
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
        )
    }
}
