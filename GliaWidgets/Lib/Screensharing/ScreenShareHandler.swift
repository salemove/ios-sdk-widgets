import SalemoveSDK

enum ScreenSharingStatus {
    case started
    case stopped
}

class ScreenShareHandler {
    let status = ObservableValue<ScreenSharingStatus>(with: .stopped)
    private var visitorState: VisitorScreenSharingState?

    func updateState(to state: VisitorScreenSharingState?) {
        visitorState = state
        guard let state = state else {
            status.value = .stopped
            return
        }
        switch state.status {
        case .sharing:
            status.value = .started
        case .notSharing:
            status.value = .stopped
        @unknown default:
            break
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        visitorState?.localScreen?.stopSharing()
        visitorState = nil
        status.value = .stopped
        completion?()
    }

    func cleanUp() {
        visitorState = nil
    }
}
