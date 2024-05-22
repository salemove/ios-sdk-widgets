import UIKit

extension Survey {
    final class ViewController: UIViewController, AlertPresenter {
        struct Props {
            let header: String
            var questionsProps: [QuestionPropsProtocol]
            var submit: (Props) -> Void
            var cancell: () -> Void
            var endEditing: () -> Void

            init(
                header: String = "",
                props: [QuestionPropsProtocol] = [],
                submit: @escaping (Props) -> Void = { _ in },
                cancel: @escaping () -> Void = {},
                endEditing: @escaping () -> Void = {}
            ) {
                self.header = header
                self.questionsProps = props
                self.submit = submit
                self.cancell = cancel
                self.endEditing = endEditing
            }
        }

        let viewFactory: ViewFactory
        private let environment: Environment

        var props: Props {
            didSet { render() }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { preconditionFailure() }

        init(
            viewFactory: ViewFactory,
            environment: Environment,
            props: Props = .init()
        ) {
            self.viewFactory = viewFactory
            self.environment = environment
            self.props = props
            self.theme = viewFactory.theme
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .overFullScreen
            modalTransitionStyle = .crossDissolve
        }

        override func loadView() {
            view = ContentView()
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            render()
            contentView.submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
            contentView.cancelButton.addTarget(self, action: #selector(cancell), for: .touchUpInside)
            subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
            subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
        }

        @objc
        private func submit(sender: UIButton) {
            props.submit(props)
        }

        @objc
        private func cancell(sender: UIButton) {
            props.cancell()
        }

        func render() {
            contentView.header.text = props.header
            contentView.header.accessibilityLabel = props.header
            if props.questionsProps.count == contentView.surveyItemsStack.arrangedSubviews.count {
                updateProps()
            } else {
                reloadProps()
            }
            contentView.updateUi(theme: theme)
            contentView.endEditing = props.endEditing
        }

        // MARK: - Private

        private let theme: Theme

        // swiftlint:disable force_cast
        private var contentView: ContentView { view as! ContentView }
        // swiftlint:enable force_cast

        private func reloadProps() {
            contentView.surveyItemsStack.removeArrangedSubviews()
            contentView.surveyItemsStack.addArrangedSubviews(
                props.questionsProps
                    .compactMap { $0.makeQuestionView(theme: theme) }
            )
        }

        private func updateProps() {
            let updates: [(UIView) -> Void] = props.questionsProps
                .compactMap { props in
                    if let inputProps = props as? Survey.InputQuestionView.Props {
                        return {
                            ($0 as? Survey.InputQuestionView)?.props = inputProps
                        }
                    } else if let scaleProps = props as? Survey.ScaleQuestionView.Props {
                        return {
                            ($0 as? Survey.ScaleQuestionView)?.props = scaleProps
                        }
                    } else if let booleanProps = props as? Survey.BooleanQuestionView.Props {
                        return {
                            ($0 as? Survey.BooleanQuestionView)?.props = booleanProps
                        }
                    } else if let singleProps = props as? Survey.SingleChoiceQuestionView.Props {
                        return {
                            ($0 as? Survey.SingleChoiceQuestionView)?.props = singleProps
                        }
                    }
                    return nil
                }

            zip(updates, contentView.surveyItemsStack.arrangedSubviews)
                .forEach { update, view in
                    update(view)
                }
        }

        deinit {
            environment.log.prefixed(Self.self).info("Destroy Survey screen")
        }
    }
}

extension Survey.QuestionPropsProtocol {
    func makeQuestionView(theme: Theme) -> UIView? {
        if let inputProps = self as? Survey.InputQuestionView.Props {
            return Survey.InputQuestionView(props: inputProps, style: theme.survey.inputQuestion)
        } else if let scaleProps = self as? Survey.ScaleQuestionView.Props {
            return Survey.ScaleQuestionView(props: scaleProps, style: theme.survey.scaleQuestion)
        } else if let booleanProps = self as? Survey.BooleanQuestionView.Props {
            return Survey.BooleanQuestionView(props: booleanProps, style: theme.survey.booleanQuestion)
        } else if let singleProps = self as? Survey.SingleChoiceQuestionView.Props {
            return Survey.SingleChoiceQuestionView(props: singleProps, style: theme.survey.singleQuestion)
        }
        return nil
    }
}

extension Survey.ViewController {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        environment.notificationCenter.addObserver(
            self,
            selector: selector,
            name: notification,
            object: nil
        )
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] {
            contentView.hideKeyboard()
            let duration = (durationValue as AnyObject).doubleValue ?? 0.3
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] {
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            contentView.showKeyboard(keyboardHeight: endRect.height)
            let duration = (durationValue as AnyObject).doubleValue ?? 0.3
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension Survey.ViewController {
    struct Environment {
        var notificationCenter: FoundationBased.NotificationCenter
        var log: CoreSdkClient.Logger
    }
}
