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
                    name: L10n.Survey.Action.yes,
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
}

private extension Survey.ViewController.Props {

    static func makeScalePropsMock(selectedOption: Survey.Option<Int>? = nil) -> Survey.ScaleQuestionView.Props {
        var props = Survey.ScaleQuestionView.Props(
            id: UUID.mock.uuidString,
            title: "Question title",
            isRequired: true,
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
        selectedOption: Survey.Option<Bool>? = nil
    ) -> Survey.BooleanQuestionView.Props {
        var props = Survey.BooleanQuestionView.Props(
            id: UUID().uuidString,
            title: "Question title",
            isRequired: true,
            accessibility: .init(value: "Required")
        )
        props.options = [
            .init(name: L10n.Survey.Action.yes, value: true),
            .init(name: L10n.Survey.Action.no, value: false)
        ].compactMap { $0 }
        props.selected = selectedOption
        return props
    }

    static func makeSinglePropsMock(
        selectedOption: Survey.Option<String>? = nil
    ) -> Survey.SingleChoiceQuestionView.Props {
        var props = Survey.SingleChoiceQuestionView.Props(
            id: UUID().uuidString,
            title: "Question title",
            isRequired: true,
            accessibility: .init(value: "Required")
        )
        props.options = [
            .init(name: "First option", value: "\(1)"),
            .init(name: "Second option", value: "\(2)"),
            .init(name: "Third option", value: "\(3)")
        ].compactMap { $0 }
        props.selected = selectedOption
        return props
    }

    static func makeInputPropsMock(
        value: String = "Feedback"
    ) -> Survey.InputQuestionView.Props {
        .init(
            id: UUID().uuidString,
            title: "Question title",
            value: value,
            isRequired: true,
            accessibility: .init(value: "Required")
        )
    }
}
#endif
