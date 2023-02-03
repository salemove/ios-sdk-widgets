import Foundation

extension CallVisualizer.ScreenSharingViewController {
    struct Props: Equatable {
        static let initial: Props = .init()

        let screenSharingViewProps: CallVisualizer.ScreenSharingView.Props

        init(screenSharingViewProps: CallVisualizer.ScreenSharingView.Props = .init()) {
            self.screenSharingViewProps = screenSharingViewProps
        }
    }
}
