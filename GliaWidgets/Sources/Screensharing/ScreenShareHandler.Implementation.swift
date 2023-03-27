import Foundation

extension ScreenShareHandler {
    static func create() -> ScreenShareHandler {
        let status = ObservableValue<ScreenSharingStatus>(with: .stopped)
        var visitorState: CoreSdkClient.VisitorScreenSharingState?

        return ScreenShareHandler(
            status: { status },
            updateState: { state in
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
            },
            stop: { completion in
                visitorState?.localScreen?.stopSharing()
                visitorState = nil
                status.value = .stopped
                completion?()
            },
            cleanUp: {
                visitorState = nil
            })
    }
}
