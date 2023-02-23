import Foundation

extension CallVisualizer {
    final class ScreenSharingViewModel {
        typealias Props = CallVisualizer.ScreenSharingViewController.Props

        private let environment: Environment
        private let style: ScreenSharingViewStyle

        var delegate: Command<DelegateEvent> = .nop

        init(
            style: ScreenSharingViewStyle,
            environment: Environment
        ) {
            self.style = style
            self.environment = environment
        }
    }
}

// MARK: - Private

extension CallVisualizer.ScreenSharingViewModel {
    func props() -> Props {
        let backButton = style.header.backButton.map {
            HeaderButton.Props(
                tap: Cmd { [weak self] in self?.delegate(.close) },
                style: $0
            )
        }

        let headerProps = Header.Props(
            title: style.title,
            effect: .none,
            endButton: .init(style: style.header.endButton),
            backButton: backButton,
            closeButton: .init(
                style: style.header.closeButton
            ),
            endScreenshareButton: .init(
                tap: Cmd { [weak self] in self?.endScreenSharing() },
                style: style.header.endScreenShareButton
            ),
            style: style.header
        )
        let endScreenSharingButtonProps = ActionButton.Props(
            style: style.buttonStyle,
            tap: Cmd { [weak self] in self?.endScreenSharing() }
        )

        let screenSharingViewProps = CallVisualizer.ScreenSharingView.Props(
            style: style,
            header: headerProps,
            endScreenSharing: endScreenSharingButtonProps
        )

        return Props(
            screenSharingViewProps: screenSharingViewProps
        )
    }

    func endScreenSharing() {
        environment.screenShareHandler.stop { [weak self] in
            self?.delegate(.close)
        }
    }
}
