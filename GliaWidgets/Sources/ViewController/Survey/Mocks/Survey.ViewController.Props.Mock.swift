#if DEBUG
import Foundation

extension Survey.ViewController.Props {
    static func emptyPropsMock() -> Survey.ViewController.Props {
        return Survey.ViewController.Props(
            header: "Survey title",
            props: [
                makeScalePropsMock(),
                makeInputPropsMock(),
                makeBooleanPropsMock(),
                makeSinglePropsMock()
            ],
            submit: { _ in },
            cancel: {}
        )
    }

    static func emptyPropsMockWithDefaultValue() -> Survey.ViewController.Props {
        return Survey.ViewController.Props(
            header: "Survey title",
            props: [
                makeScalePropsMock(),
                makeInputPropsMock(),
                makeBooleanPropsMock(),
                makeSinglePropsMock(defaultOption: .init(
                    name: "Second option",
                    value: "\(2)"
                ))
            ],
            submit: { _ in },
            cancel: {}
        )
    }

    static func filledPropsMock() -> Survey.ViewController.Props {
        return Survey.ViewController.Props(
            header: "Survey title",
            props: [
                makeScalePropsMock(selectedOption: .init(
                    name: "1",
                    value: 1
                )),
                makeInputPropsMock(),
                makeBooleanPropsMock(selectedOption: .init(
                    name: Localization.General.yes,
                    value: true
                )),
                makeSinglePropsMock(selectedOption: .init(
                    name: "First option",
                    value: "\(1)"
                ))
            ],
            submit: { _ in },
            cancel: {}
        )
    }

    static func errorPropsMock() -> Survey.ViewController.Props {
        return Survey.ViewController.Props(
            header: "Survey title",
            props: [
                makeScalePropsMock(showValidationError: true),
                makeInputPropsMock(showValidationError: true),
                makeBooleanPropsMock(showValidationError: true),
                makeSinglePropsMock(showValidationError: true)
            ],
            submit: { _ in },
            cancel: {}
        )
    }
}

private extension Survey.ViewController.Props {

    static func makeScalePropsMock(
        selectedOption: Survey.Option<Int>? = nil,
        showValidationError: Bool = false
    ) -> Survey.ScaleQuestionView.Props {
        var props = Survey.ScaleQuestionView.Props(
            id: UUID.mock.uuidString,
            title: "Question title",
            isRequired: true,
            showValidationError: showValidationError,
            accessibility: .init(value: "Required")
        )
        props.options = [
            .init(name: "1", value: 1),
            .init(name: "2", value: 2),
            .init(name: "3", value: 3),
            .init(name: "4", value: 4),
            .init(name: "5", value: 5)
        ].compactMap { $0 }
        props.selected = selectedOption
        return props
    }

    static func makeBooleanPropsMock(
        selectedOption: Survey.Option<Bool>? = nil,
        showValidationError: Bool = false
    ) -> Survey.BooleanQuestionView.Props {
        var props = Survey.BooleanQuestionView.Props(
            id: UUID().uuidString,
            title: "Question title",
            isRequired: true,
            showValidationError: showValidationError,
            accessibility: .init(value: "Required")
        )
        props.options = [
            .init(name: Localization.General.yes, value: true),
            .init(name: Localization.General.no, value: false)
        ].compactMap { $0 }
        props.selected = selectedOption
        return props
    }

    static func makeSinglePropsMock(
        selectedOption: Survey.Option<String>? = nil,
        defaultOption: Survey.Option<String>? = nil,
        showValidationError: Bool = false
    ) -> Survey.SingleChoiceQuestionView.Props {
        var props = Survey.SingleChoiceQuestionView.Props(
            id: UUID().uuidString,
            title: "Question title",
            isRequired: true,
            showValidationError: showValidationError,
            accessibility: .init(value: "Required")
        )
        props.options = [
            .init(name: "First option", value: "\(1)"),
            .init(name: "Second option", value: "\(2)"),
            .init(name: "Third option", value: "\(3)")
        ].compactMap { $0 }
        props.defaultOption = defaultOption
        props.selected = selectedOption
        return props
    }

    static func makeInputPropsMock(
        value: String = "Feedback",
        showValidationError: Bool = false
    ) -> Survey.InputQuestionView.Props {
        .init(
            id: UUID().uuidString,
            title: "Question title",
            value: value,
            isRequired: true,
            showValidationError: showValidationError,
            accessibility: .init(
                titleValue: "Required",
                fieldHint: nil
            )
        )
    }
}
#endif
