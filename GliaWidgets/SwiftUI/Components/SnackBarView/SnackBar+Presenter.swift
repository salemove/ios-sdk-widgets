import Combine
import SwiftUI
import UIKit

extension SnackBar {
    final class Presenter {
        weak var parentViewController: UIViewController?

        let hostingController: UIHostingController<ContentView>
        let updatePublisher: CurrentValueSubject<ContentView.ViewState, Never>

        private let environment: Environment
        private var serialQueue = SerialQueue()
        private var timer: FoundationBased.Timer?

        init(
            parentViewController: UIViewController,
            style: Theme.SnackBarStyle,
            environment: Environment
        ) {
            self.parentViewController = parentViewController
            let publisher = CurrentValueSubject<ContentView.ViewState, Never>(.disappear)
            self.updatePublisher = publisher
            self.hostingController = .init(
                rootView: .init(
                    style: style,
                    publisher: publisher.eraseToAnyPublisher()
                )
            )
            self.environment = environment
            self.monitorKeyboard()
        }

        func add() {
            guard let parent = parentViewController else { return }
            remove()

            parent.addChild(hostingController)
            hostingController.willMove(toParent: parent)
            parent.view.addSubview(hostingController.view)
            hostingController.didMove(toParent: parent)
            hostingController.view.backgroundColor = .clear

            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
             NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(greaterThanOrEqualTo: parent.view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 64),
                hostingController.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor)
             ])
        }

        func remove() {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }

        func show(
            text: String,
            with offset: CGFloat
        ) {
            serialQueue.addOperation(
                .init { [weak self] done in
                    self?.hostingController.rootView.offset = offset
                    self?.updatePublisher.send(.appear(text))

                    self?.timer?.invalidate()

                    self?.timer = self?.environment.timerProviding.scheduledTimer(
                        withTimeInterval: 3,
                        repeats: false
                    ) { [weak self] _ in
                        self?.updatePublisher.send(.disappear)
                        self?.environment.gcd.mainQueue.asyncAfterDeadline(.now() + 0.5) { [weak self] in
                            self?.remove()
                        }
                        done()
                    }
                }
            )
        }
    }
}

private extension SnackBar.Presenter {
    func monitorKeyboard() {
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
    }

    func subscribeToNotification(
        _ notification: NSNotification.Name,
        selector: Selector
    ) {
        environment.notificationCenter.addObserver(
            self,
            selector: selector,
            name: notification,
            object: nil
        )
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        self.updatePublisher.send(.keyboardWillShow)
    }
}

extension SnackBar.Presenter {
    struct Environment {
        let timerProviding: FoundationBased.Timer.Providing
        let notificationCenter: FoundationBased.NotificationCenter
        let gcd: GCD
    }
}
