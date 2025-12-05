import Foundation

extension CallVisualizer.VideoCallViewModel {
    enum DelegateEvent {
        case propsUpdated(Props)
        case minimized
        case showSnackBarView(dismissTiming: SnackBar.DismissTiming, style: Theme.SnackBarStyle)
    }
}
