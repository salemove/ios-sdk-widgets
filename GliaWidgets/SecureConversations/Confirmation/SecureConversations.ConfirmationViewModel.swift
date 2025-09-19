import Foundation
import UIKit
import Combine

extension SecureConversations.ConfirmationViewSwiftUI {
    final class Model: ObservableObject {
        private var isViewActive = ObservableValue<Bool>(with: false)
        @Published private(set) var orientation: UIInterfaceOrientation
        let environment: Environment
        let style: SecureConversations.ConfirmationStyle
        var delegate: ((DelegateEvent) -> Void)?
        let orientationManager: OrientationManager
        var cancellables: Set<AnyCancellable> = []

        init(
            environment: Environment,
            style: SecureConversations.ConfirmationStyle,
            delegate: ((DelegateEvent) -> Void)?
        ) {
            self.environment = environment
            self.style = style
            self.delegate = delegate
            self.orientationManager = environment.orientationManager
            self.orientation = orientationManager.orientation
            orientationManager.$orientation.sink { [weak self] orientation in
                self?.orientation = orientation
            }.store(in: &self.cancellables)
            isViewActive.addObserver(self) { [weak self] isViewActive, _ in
                if isViewActive {
                    self?.environment.openTelemetry.logger.i(.scConfirmationScreenShown)
                } else {
                    self?.environment.openTelemetry.logger.i(.scConfirmationScreenClosed)
                }
            }
        }
    }
}

// MARK: - Public Methods
extension SecureConversations.ConfirmationViewSwiftUI.Model {
    func event(_ event: Event) {
        switch event {
        case .closeTapped:
            logButtonClicked(.close)
            delegate?(.closeTapped)
        case .chatTranscriptScreenRequested:
            logButtonClicked(.checkMessages)
            delegate?(.chatTranscriptScreenRequested)
        case .viewDidAppear:
            isViewActive.value = true
        case .viewDidDisappear:
            isViewActive.value = false
        }
    }
}

// MARK: - Private Methods
extension SecureConversations.ConfirmationViewSwiftUI.Model {
    func makeHeaderModel() -> HeaderSwiftUI.Model {
        let endButtonProps: ActionButtonSwiftUI.Model = .init(
            style: style.header.endButton,
            accessibilityIdentifier: "header_end_button",
            isEnabled: false,
            isHidden: true
        )

        let closeButtonProps: HeaderButtonSwiftUI.Model = .init(
            tap: Cmd(closure: { [weak self] in
                self?.event(.closeTapped)
            }),
            style: style.header.closeButton,
            accessibilityIdentifier: "header_close_button",
            isEnabled: true,
            isHidden: false
        )

        let environment: HeaderSwiftUI.Environment = .init(uiApplication: environment.uiApplication)

        return .init(
            title: style.headerTitle,
            effect: .none,
            endButton: endButtonProps,
            backButton: nil,
            closeButton: closeButtonProps,
            style: style.header,
            environment: environment
        )
    }
}

// MARK: - OpenTelemetry
extension SecureConversations.ConfirmationViewSwiftUI.Model {
    private func logButtonClicked(_ button: OtelButtonNames) {
        environment.openTelemetry.logger.i(.scConfirmationScreenButtonClicked) {
            $0[.buttonName] = .string(button.rawValue)
        }
    }
}

// MARK: - Objects
extension SecureConversations.ConfirmationViewSwiftUI.Model {
    enum Event {
        case closeTapped
        case chatTranscriptScreenRequested
        case viewDidAppear
        case viewDidDisappear
    }

    enum DelegateEvent {
        case closeTapped
        case chatTranscriptScreenRequested
    }
}
