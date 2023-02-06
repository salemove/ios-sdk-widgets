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

// MARK: - Private

private extension CallVisualizer.ScreenSharingViewModel {
    func props() -> Props {
        return Props(
            screenSharingViewProps: .init(
                style: style,
                endScreenSharing: .init { [weak self] in
                    self?.endScreenSharing()
                },
                back: .init { [weak self] in
                    self?.delegate(.close)
                }
            )
        )
    }

    func endScreenSharing() {
        environment.screenShareHandler.stop { [weak self] in
            self?.delegate(.close)
        }
    }
}
