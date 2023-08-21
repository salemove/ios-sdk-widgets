import Foundation

extension Survey.ViewController.Props {
    // swiftlint:disable function_body_length
    static func live(
        sdkSurvey: CoreSdkClient.Survey,
        engagementId: String,
        submitSurveyAnswer: @escaping CoreSdkClient.SubmitSurveyAnswer,
        cancel: @escaping () -> Void,
        endEditing: @escaping () -> Void,
        updateProps: @escaping (Self) -> Void,
        onError: @escaping (Error) -> Void,
        completion: @escaping () -> Void
    ) -> Self {
        var props = Survey.ViewController.Props(
            header: sdkSurvey.title,
            submit: { _ in },
            cancel: cancel,
            endEditing: endEditing
        )

        var questions = [String: SurveyQuestionPropsProtocol]()
        let questionsOrder = sdkSurvey.questions.map(\.id.rawValue)

        sdkSurvey.questions.forEach { sdkQuestion in
            switch sdkQuestion.type {
            case .scale:
                questions[sdkQuestion.id.rawValue] = makeScaleProps(
                    props: { props },
                    sdkQuestion: sdkQuestion,
                    getQuestion: { questions[$0] },
                    getQuestions: { questionsOrder.compactMap { questions[$0] } },
                    setQuestion: { questions[$0] = $1; props.endEditing() },
                    updateProps: updateProps
                )

            case .boolean:
                questions[sdkQuestion.id.rawValue] = makeBooleanProps(
                    props: { props },
                    sdkQuestion: sdkQuestion,
                    getQuestion: { questions[$0] },
                    getQuestions: { questionsOrder.compactMap { questions[$0] } },
                    setQuestion: { questions[$0] = $1; props.endEditing() },
                    updateProps: updateProps
                )

            case .text:
                questions[sdkQuestion.id.rawValue] = makeInputProps(
                    props: { props },
                    sdkQuestion: sdkQuestion,
                    getQuestion: { questions[$0] },
                    getQuestions: { questionsOrder.compactMap { questions[$0] } },
                    setQuestion: { questions[$0] = $1 },
                    updateProps: updateProps
                )
            case .singleChoice:
                questions[sdkQuestion.id.rawValue] = makeSingleProps(
                    props: { props },
                    sdkQuestion: sdkQuestion,
                    getQuestion: { questions[$0] },
                    getQuestions: { questionsOrder.compactMap { questions[$0] } },
                    setQuestion: { questions[$0] = $1; props.endEditing() },
                    updateProps: updateProps
                )

            @unknown default:
                break
            }
        }

        props.questionsProps = questionsOrder.compactMap { questions[$0] }
        props.submit = { currentProps in
            if currentProps.questionsProps.contains(where: { !$0.isValid }) {
                updateProps(validate(props: currentProps, setQuestion: { questions[$0] = $1 }))
                return
            }

            submitSurveyAnswer(
                currentProps.toCoreSdkAnswers(),
                sdkSurvey.id,
                engagementId
            ) { result in
                guard case .failure(let error) = result else { return completion() }
                onError(error)
            }
        }
        return props
    }
    // swiftlint:enable function_body_length

    static func validate(
        props: Self,
        setQuestion: (String, Survey.QuestionPropsProtocol) -> Void
    ) -> Self {
        var newProps = props
        newProps.questionsProps = newProps.questionsProps
            .map { question -> SurveyQuestionPropsProtocol in
                guard !question.isValid else { return question }
                var invalid = question
                invalid.showValidationError = true
                setQuestion(question.id, invalid)
                return invalid
            }
        return newProps
    }

    private func toCoreSdkAnswers() -> [CoreSdkClient.Survey.Answer] {
        questionsProps.compactMap {
            guard let response = $0.answerContainer else { return nil }
            return .init(questionId: .init(rawValue: $0.id), response: response)
        }
    }
}

extension Survey.ViewController.Props {
    static func makeScaleProps(
        props: @escaping () -> Self,
        sdkQuestion: CoreSdkClient.Survey.Question,
        getQuestion: @escaping (String) -> SurveyQuestionPropsProtocol?,
        getQuestions: @escaping () -> [SurveyQuestionPropsProtocol],
        setQuestion: @escaping (String, SurveyQuestionPropsProtocol) -> Void,
        updateProps: @escaping (Self) -> Void
    ) -> Survey.ScaleQuestionView.Props {

        let accessibilityValue = sdkQuestion.required
        ? Localization.Survey.Question.Title.Accessibility.label
        : nil

        var scaleProps = Survey.ScaleQuestionView.Props(
            id: sdkQuestion.id.rawValue,
            title: sdkQuestion.text,
            isRequired: sdkQuestion.required,
            accessibility: .init(value: accessibilityValue)
        )
        let handleScaleOptionSelection = { (option: Survey.Option<Int>) in
            guard var optionProps = getQuestion(sdkQuestion.id.rawValue) as? Survey.ScaleQuestionView.Props else { return }
            optionProps.selected = option
            optionProps.showValidationError = false
            optionProps.answerContainer = .int(option.value)
            setQuestion(sdkQuestion.id.rawValue, optionProps)
            var newViewControllerProps = props()
            newViewControllerProps.questionsProps = getQuestions()
            updateProps(newViewControllerProps)
        }
        scaleProps.options = [
            .init(name: "1", value: 1, select: handleScaleOptionSelection),
            .init(name: "2", value: 2, select: handleScaleOptionSelection),
            .init(name: "3", value: 3, select: handleScaleOptionSelection),
            .init(name: "4", value: 4, select: handleScaleOptionSelection),
            .init(name: "5", value: 5, select: handleScaleOptionSelection)
        ]

        return scaleProps
    }

    static func makeBooleanProps(
        props: @escaping () -> Self,
        sdkQuestion: CoreSdkClient.Survey.Question,
        getQuestion: @escaping (String) -> SurveyQuestionPropsProtocol?,
        getQuestions: @escaping () -> [SurveyQuestionPropsProtocol],
        setQuestion: @escaping (String, SurveyQuestionPropsProtocol) -> Void,
        updateProps: @escaping (Self) -> Void
    ) -> Survey.BooleanQuestionView.Props {

        let accessibilityValue = sdkQuestion.required
        ? Localization.Survey.Question.Title.Accessibility.label
        : nil

        var booleanProps = Survey.BooleanQuestionView.Props(
            id: sdkQuestion.id.rawValue,
            title: sdkQuestion.text,
            isRequired: sdkQuestion.required,
            accessibility: .init(value: accessibilityValue)
        )
        let handleBooleanOptionSelection = { (option: Survey.Option<Bool>) in
            guard var optionProps = getQuestion(sdkQuestion.id.rawValue) as? Survey.BooleanQuestionView.Props else { return }
            optionProps.selected = option
            optionProps.showValidationError = false
            optionProps.answerContainer = .boolean(option.value)
            setQuestion(sdkQuestion.id.rawValue, optionProps)
            var newViewControllerProps = props()
            newViewControllerProps.questionsProps = getQuestions()
            updateProps(newViewControllerProps)
        }
        booleanProps.options = [
            .init(name: Localization.General.yes, value: true, select: handleBooleanOptionSelection),
            .init(name: Localization.General.no, value: false, select: handleBooleanOptionSelection)
        ]

        return booleanProps
    }

    static func makeSingleProps(
        props: @escaping () -> Self,
        sdkQuestion: CoreSdkClient.Survey.Question,
        getQuestion: @escaping (String) -> SurveyQuestionPropsProtocol?,
        getQuestions: @escaping () -> [SurveyQuestionPropsProtocol],
        setQuestion: @escaping (String, SurveyQuestionPropsProtocol) -> Void,
        updateProps: @escaping (Self) -> Void
    ) -> Survey.SingleChoiceQuestionView.Props {

        let accessibilityValue = sdkQuestion.required
        ? Localization.Survey.Question.Title.Accessibility.label
        : nil

        var scaleProps = Survey.SingleChoiceQuestionView.Props(
            id: sdkQuestion.id.rawValue,
            title: sdkQuestion.text,
            isRequired: sdkQuestion.required,
            accessibility: .init(value: accessibilityValue)
        )
        let handleSingleOptionSelection = { (option: Survey.Option<String>) in
            guard var optionProps = getQuestion(sdkQuestion.id.rawValue) as? Survey.SingleChoiceQuestionView.Props else { return }
            optionProps.selected = option
            optionProps.showValidationError = false
            optionProps.answerContainer = .string(option.value)
            setQuestion(sdkQuestion.id.rawValue, optionProps)
            var newViewControllerProps = props()
            newViewControllerProps.questionsProps = getQuestions()
            updateProps(newViewControllerProps)
        }
        scaleProps.options = sdkQuestion.options?
            .map { sdkOption in
                    .init(
                        name: sdkOption.label,
                        value: sdkOption.id.rawValue,
                        select: handleSingleOptionSelection
                    )
            } ?? []

        return scaleProps
    }

    static func makeInputProps(
        props: @escaping () -> Self,
        sdkQuestion: CoreSdkClient.Survey.Question,
        getQuestion: @escaping (String) -> SurveyQuestionPropsProtocol?,
        getQuestions: @escaping () -> [SurveyQuestionPropsProtocol],
        setQuestion: @escaping (String, SurveyQuestionPropsProtocol) -> Void,
        updateProps: @escaping (Self) -> Void
    ) -> Survey.InputQuestionView.Props {

        let accessibilityValue = sdkQuestion.required
        ? Localization.Survey.Question.Title.Accessibility.label
        : nil

        var inputProps = Survey.InputQuestionView.Props(
            id: sdkQuestion.id.rawValue,
            title: sdkQuestion.text,
            isRequired: sdkQuestion.required,
            accessibility: .init(
                titleValue: accessibilityValue,
                fieldHint: Localization.Survey.Question.TextField.Accessibility.hint
            )
        )
        inputProps.textDidChange = { newValue in
            guard var newQuestion = getQuestion(sdkQuestion.id.rawValue) as? Survey.InputQuestionView.Props else { return }
            newQuestion.value = newValue
            newQuestion.showValidationError = false
            newQuestion.answerContainer = .string(newValue)
            setQuestion(sdkQuestion.id.rawValue, newQuestion)
            var newProps = props()
            newProps.questionsProps = getQuestions()
            updateProps(newProps)
        }

        return inputProps
    }
}
