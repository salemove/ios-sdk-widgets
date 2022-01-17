import SalemoveSDK

enum ScreenSharingStatus {
    case started
    case stopped
}

class ScreenShareHandler {
    var status: Observable<ScreenSharingStatus> {
        return statusSubject
    }

    private let statusSubject = CurrentValueSubject<ScreenSharingStatus>(.stopped)
    private var visitorState: VisitorScreenSharingState?

    func updateState(to state: VisitorScreenSharingState?) {
        visitorState = state

        guard let state = state else {
            statusSubject.send(.stopped)
            return
        }

        switch state.status {
        case .sharing:
            statusSubject.send(.started)

        case .notSharing:
            statusSubject.send(.stopped)

        @unknown default:
            break
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        visitorState?.localScreen?.stopSharing()
        visitorState = nil
        statusSubject.send(.stopped)
        completion?()
    }

    func cleanUp() {
        visitorState = nil
    }
}
