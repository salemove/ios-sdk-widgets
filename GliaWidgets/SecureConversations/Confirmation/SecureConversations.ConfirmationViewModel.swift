import Foundation
import UIKit
import Combine

extension SecureConversations.ConfirmationViewSwiftUI {
    final class Model: ObservableObject {
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
        }
    }
}

// MARK: - Public Methods
extension SecureConversations.ConfirmationViewSwiftUI.Model {
    func event(_ event: Event) {
        switch event {
        case .closeTapped:
            delegate?(.closeTapped)
        case .chatTranscriptScreenRequested:
            delegate?(.chatTranscriptScreenRequested)
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
                self?.delegate?(.closeTapped)
            }),
            style: style.header.closeButton,
            accessibilityIdentifier: "header_close_button",
            isEnabled: true,
            isHidden: false
        )

        let endScreenShareButtonProps: HeaderButtonSwiftUI.Model = .init(
            style: style.header.endScreenShareButton,
            accessibilityIdentifier: "header_end_screen_sharing_button",
            isEnabled: false,
            isHidden: true
        )

        let environment: HeaderSwiftUI.Environment = .init(uiApplication: environment.uiApplication)

        return .init(
            title: style.headerTitle,
            effect: .none,
            endButton: endButtonProps,
            backButton: nil,
            closeButton: closeButtonProps,
            endScreenshareButton: endScreenShareButtonProps,
            style: style.header,
            environment: environment
        )
    }
}

// MARK: - Objects
extension SecureConversations.ConfirmationViewSwiftUI.Model {
    enum Event {
        case closeTapped
        case chatTranscriptScreenRequested
    }

    enum DelegateEvent {
        case closeTapped
        case chatTranscriptScreenRequested
    }

    struct Environment {
        var orientationManager: OrientationManager
        var uiApplication: UIKitBased.UIApplication
    }
}
