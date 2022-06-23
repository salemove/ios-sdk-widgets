import XCTest

@testable import GliaWidgets

final class FileUploadListViewTests: XCTestCase {
    private var view: FileUploadListView!

    func test_maxUnscrollableViewsWithMediumPreferredContentSizeCategory() throws {
        func testCase(input: (category: UIContentSizeCategory, maxViewCount: Int)) throws {
            var environment = FileUploadListView.Environment(
                uiApplication: .failing
            )

            environment.uiApplication.preferredContentSizeCategory = {
                return input.category
            }

            view = .mock(environment: environment)

            XCTAssertEqual(view.maxUnscrollableViews, input.maxViewCount)
        }

        let input: [(UIContentSizeCategory, Int)] = [
            (.unspecified, 3),
            (.extraSmall, 3),
            (.small, 3),
            (.medium, 3),
            (.large, 3),
            (.extraLarge, 3),
            (.extraExtraLarge, 3),
            (.extraExtraExtraLarge, 3),
            (.accessibilityMedium, 3),
            (.accessibilityLarge, 2),
            (.accessibilityExtraLarge, 2),
            (.accessibilityExtraExtraLarge, 2),
            (.accessibilityExtraExtraExtraLarge, 2)
        ]

        try input.forEach(testCase)
    }
}
