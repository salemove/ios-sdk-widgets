import Foundation
import XCTest
@testable import GliaWidgets

final class SurveySingleChoiceQuestionViewTests: XCTestCase {
    static let firstOption = Survey.Option(name: "Option 1", value: "1")
    static let secondOption = Survey.Option(name: "Option 2", value: "2")

    var props: Survey.SingleChoiceQuestionView.Props = {
        var props = Survey.SingleChoiceQuestionView.Props(
            id: "1",
            title: "Survey",
            isRequired: true,
            accessibility: .init(value: "")
        )
        props.options = [
            firstOption,
            secondOption
        ]
        return props
    }()

    func test_regularOptionIsActive() {
        let regularOption = Self.firstOption

        let selection = Survey.SingleChoiceQuestionView.handleSelection(
            with: props,
            option: regularOption
        )

        XCTAssertEqual(selection, .active)
    }

    func test_defaultOptionIsSelected() {
        var hasSelectedDefaultOption = false

        let defaultOption = Survey.Option<String>(
            name: "Option 1",
            value: "1",
            select: { _ in
                hasSelectedDefaultOption = true
            }
        )

        props.defaultOption = defaultOption
        props.options = [defaultOption, Self.secondOption]

        let selection = Survey.SingleChoiceQuestionView.handleSelection(
            with: props,
            option: defaultOption
        )

        XCTAssertEqual(selection, .selected)
        XCTAssertEqual(hasSelectedDefaultOption, true)
    }

    func test_regularOptionIsActiveWhenDefaultIsPresent() {
        let defaultOption = Self.firstOption
        props.defaultOption = defaultOption

        let selection = Survey.SingleChoiceQuestionView.handleSelection(
            with: props,
            option: Self.secondOption
        )

        XCTAssertEqual(selection, .active)
    }

    func test_selectedOptionIsSelected() {
        let selectedOption = Self.firstOption
        props.selected = selectedOption

        let selection = Survey.SingleChoiceQuestionView.handleSelection(
            with: props,
            option: selectedOption
        )

        XCTAssertEqual(selection, .selected)
    }

    func test_regularOptionIsActiveWhenSelectedIsPresent() {
        let selectedOption = Self.firstOption
        props.selected = selectedOption

        let selection = Survey.SingleChoiceQuestionView.handleSelection(
            with: props,
            option: Self.secondOption
        )

        XCTAssertEqual(selection, .active)
    }
}
