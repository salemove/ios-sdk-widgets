import SwiftUI
import Combine

extension CallVisualizer.ScreenSharingView {
    final class Model: ObservableObject {
        @Published private(set) var orientation: UIInterfaceOrientation
        let style: ScreenSharingViewStyle
        let environment: Environment
        let orientationManager: OrientationManager
        var delegate: Command<DelegateEvent> = .nop
        var cancellables: Set<AnyCancellable> = []

        init(style: ScreenSharingViewStyle, environment: Environment) {
            self.style = style
            self.environment = environment
            self.orientationManager = environment.orientationManager
            self.orientation = orientationManager.orientation

            orientationManager.$orientation
                .sink { [weak self] orientation in
                    self?.orientation = orientation
                }
                .store(in: &self.cancellables)
        }
    }
}

extension CallVisualizer.ScreenSharingView.Model {
    func event(_ event: Event) {
        switch event {
        case .closeTapped:
            delegate(.closeTapped)
        case .endScreenShareTapped:
            endScreenSharing()
        }
    }

    func makeHeaderModel() -> HeaderSwiftUI.Model {
        let endButtonProps: ActionButtonSwiftUI.Model = .init(
            style: style.header.endButton,
            accessibilityIdentifier: "header_end_button",
            isEnabled: false,
            isHidden: true
        )

        var backButton: HeaderButtonSwiftUI.Model?
        if let endButtonStyle = style.header.backButton {
            backButton = .init(
                tap: Cmd { [weak self] in
                    self?.delegate(.closeTapped)
                },
                style: endButtonStyle,
                accessibilityIdentifier: "header_back_button",
                size: .init(width: 20, height: 20),
                isEnabled: true,
                isHidden: false
            )
        }

        let closeButtonProps: HeaderButtonSwiftUI.Model = .init(
            style: style.header.closeButton,
            accessibilityIdentifier: "header_close_button",
            isEnabled: false,
            isHidden: true
        )

        let endScreenShareButtonProps: HeaderButtonSwiftUI.Model = .init(
            style: style.header.endScreenShareButton,
            accessibilityIdentifier: "header_end_screen_sharing_button",
            isEnabled: false,
            isHidden: true
        )

        let environment: HeaderSwiftUI.Environment = .init(uiApplication: environment.uiApplication)

        return .init(
            title: style.title,
            effect: .none,
            endButton: endButtonProps,
            backButton: backButton,
            closeButton: closeButtonProps,
            endScreenshareButton: endScreenShareButtonProps,
            style: style.header,
            environment: environment
        )
    }
}

private extension CallVisualizer.ScreenSharingView.Model {
    func endScreenSharing() {
        environment.screenShareHandler.stop(nil)
    }
}

extension CallVisualizer.ScreenSharingView.Model {
    struct Environment {
        let orientationManager: OrientationManager
        let uiApplication: UIKitBased.UIApplication
        let screenShareHandler: ScreenShareHandler
    }

    enum DelegateEvent {
        case closeTapped
    }

    enum Event {
        case closeTapped
        case endScreenShareTapped
    }
}
