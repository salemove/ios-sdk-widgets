import Foundation
@testable import GliaWidgets
import XCTest

final class SingleChoiceQuestionViewTests: XCTestCase {

    func testHandleSelectionWhenNoOptionIsSelected() {
        enum Call: Equatable { case select(Survey.Option<String>) }
        var calls: [Call] = []

        let failureClosure: (Survey.Option<String>) -> Void = { option in
            XCTFail("Non-default option \(option) should be selected programmatically")
        }
        let firstOption = Survey.Option<String>(name: "First option", value: "\(1)", select: failureClosure)
        let secondOption = Survey.Option<String>.init(name: "Second option", value: "\(2)") { option in
            calls.append(.select(option))
        }
        let thirdOption = Survey.Option<String>.init(name: "Third option", value: "\(3)", select: failureClosure)

        let props = Survey.ViewController.Props.makeSinglePropsMock(
            options: [
                firstOption,
                secondOption,
                thirdOption
            ],
            selectedOption: nil,
            defaultOption: secondOption,
            showValidationError: false
        )
        
        [
            (firstOption, .active),
            (secondOption, .selected),
            (thirdOption, .active)
        ].forEach {
            testOption($0, props: props, expectedState: $1)
        }

        XCTAssertEqual(calls, [.select(secondOption)])
    }

    func testHandleSelectionWhenNonDefaultOptionIsSelected() {
        let failureClosure: (Survey.Option<String>) -> Void = { option in
            XCTFail("Non of options should be selected programmatically if selected option already exists")
        }
        let firstOption = Survey.Option<String>(name: "First option", value: "\(1)", select: failureClosure)
        let secondOption = Survey.Option<String>.init(name: "Second option", value: "\(2)", select: failureClosure)
        let thirdOption = Survey.Option<String>.init(name: "Third option", value: "\(3)", select: failureClosure)

        let props = Survey.ViewController.Props.makeSinglePropsMock(
            options: [
                firstOption,
                secondOption,
                thirdOption
            ],
            selectedOption: firstOption,
            defaultOption: secondOption,
            showValidationError: false
        )

        [
            (firstOption, .selected),
            (secondOption, .active),
            (thirdOption, .active)
        ].forEach {
            testOption($0, props: props, expectedState: $1)
        }
    }

    func testHandleSelectionWhenDefaultOptionIsSelected() {
        let failureClosure: (Survey.Option<String>) -> Void = { option in
            XCTFail("Non of options should be selected programmatically if selected option already exists")
        }
        let firstOption = Survey.Option<String>(name: "First option", value: "\(1)", select: failureClosure)
        let secondOption = Survey.Option<String>.init(name: "Second option", value: "\(2)", select: failureClosure)
        let thirdOption = Survey.Option<String>.init(name: "Third option", value: "\(3)", select: failureClosure)

        let props = Survey.ViewController.Props.makeSinglePropsMock(
            options: [
                firstOption,
                secondOption,
                thirdOption
            ],
            selectedOption: secondOption,
            defaultOption: secondOption,
            showValidationError: false
        )

        [
            (firstOption, .active),
            (secondOption, .selected),
            (thirdOption, .active)
        ].forEach {
            testOption($0, props: props, expectedState: $1)
        }
    }
}

private extension SingleChoiceQuestionViewTests {
    func testOption(
        _ option: Survey.Option<String>,
        props: Survey.SingleChoiceQuestionView.Props,
        expectedState: Survey.CheckboxView.State
    ) {
        let state = Survey.SingleChoiceQuestionView.handleSelection(
            with: props,
            option: option
        )

        XCTAssertEqual(state, expectedState)
    }
}
