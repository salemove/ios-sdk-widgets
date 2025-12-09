import Combine
import SwiftUI
import UIKit

extension SnackBar {
    final class Presenter {
        weak var parentViewController: UIViewController?

        let hostingController: UIHostingController<ContentView>
        let updatePublisher: CurrentValueSubject<ContentView.ViewState, Never>

        private let environment: Environment
        private let configuration: Configuration
        private var serialQueue = SerialQueue()
        private var timer: FoundationBased.Timer?

        init(
            parentViewController: UIViewController,
            configuration: Configuration,
            style: Theme.SnackBarStyle,
            environment: Environment
        ) {
            self.parentViewController = parentViewController
            self.configuration = configuration
            self.environment = environment

            let publisher = CurrentValueSubject<ContentView.ViewState, Never>(.disappear)
            self.updatePublisher = publisher

            self.hostingController = .init(
                rootView: .init(
                    style: style,
                    publisher: publisher.eraseToAnyPublisher()
                )
            )
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

            guard let parentView = parent.view else { return }

            if let anchorView = configuration.anchorViewProvider?(),
                anchorView.isDescendant(of: parentView) {
                NSLayoutConstraint.activate([
                    hostingController.view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                    hostingController.view.bottomAnchor.constraint(
                        equalTo: anchorView.topAnchor,
                        constant: -configuration.anchorGap
                    ),
                    hostingController.view.topAnchor.constraint(
                        greaterThanOrEqualTo: parentView.topAnchor
                    )
                ])
            } else {
                NSLayoutConstraint.activate([
                    hostingController.view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                    hostingController.view.bottomAnchor.constraint(
                        equalTo: parentView.safeAreaLayoutGuide.bottomAnchor,
                        constant: configuration.baseOffset
                    ),
                    hostingController.view.topAnchor.constraint(
                        greaterThanOrEqualTo: parentView.topAnchor
                    )
                ])
            }
        }

        func remove() {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }

        func show(
            text: String,
            style: Theme.SnackBarStyle,
            dismissTiming: DismissTiming
        ) {
            serialQueue.addOperation(
                .init { [weak self] done in
                    guard let self else {
                        done()
                        return
                    }
                    self.updateStyle(style)
                    self.updatePublisher.send(.appear(text))

                    self.timer?.invalidate()

                    switch dismissTiming {
                    case let .auto(timeInterval):
                        self.timer = self.environment.timerProviding.scheduledTimer(
                            withTimeInterval: timeInterval,
                            repeats: false
                        ) { _ in
                            self.updatePublisher.send(.disappear)
                            self.environment.gcd.mainQueue.asyncAfterDeadline(.now() + 0.5) {
                                self.remove()
                                done()
                            }
                        }

                    case let .manual(dismiss):
                        let dismissAction = {
                            self.updatePublisher.send(.disappear)
                            self.environment.gcd.mainQueue.asyncAfterDeadline(.now() + 0.5) {
                                self.remove()
                                done()
                            }
                        }
                        dismiss(dismissAction)
                    }
                }
            )
        }

        func updateStyle(_ style: Theme.SnackBarStyle) {
            hostingController.rootView = .init(
                style: style,
                publisher: updatePublisher.eraseToAnyPublisher()
            )
        }
    }
}

extension SnackBar.Presenter {
    struct Environment {
        let timerProviding: FoundationBased.Timer.Providing
        let gcd: GCD
    }
}
