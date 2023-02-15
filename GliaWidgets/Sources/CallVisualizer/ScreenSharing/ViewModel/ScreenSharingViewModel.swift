import Foundation

extension CallVisualizer {
    final class ScreenSharingViewModel {
        typealias Props = CallVisualizer.ScreenSharingViewController.Props

        private let delegate: Command<DelegateEvent>
        private let environment: Environment
        private let style: ScreenSharingViewStyle

        init(
            style: ScreenSharingViewStyle,
            delegate: Command<DelegateEvent>,
            environment: Environment
        ) {
            self.style = style
            self.delegate = delegate
            self.environment = environment

            delegate(.propsUpdated(props()))
        }
    }
}

// MARK: - Props Generation

extension CallVisualizer.ScreenSharingViewModel {
    func props() -> Props {
        let headerProps = Header.Props(
            title: "",
            effect: .none,
            endButton: .init(
                style: style.header.endButton,
                title: style.header.endButton.title
            ),
            backButton: .init(
                tap: Cmd { [delegate] in delegate(.close) },
                style: style.header.backButton),
            closeButton: .init(style: style.header.closeButton),
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
            headerProps: headerProps,
            endScreenSharingButtonProps: endScreenSharingButtonProps
        )

        return Props(
            screenSharingViewProps: screenSharingViewProps
        )
    }

    private func endScreenSharing() {
        environment.screenShareHandler.stop { [weak self] in
            self?.delegate(.close)
        }
    }
}
