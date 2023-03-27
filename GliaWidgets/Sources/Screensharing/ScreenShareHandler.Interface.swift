enum ScreenSharingStatus {
    case started
    case stopped
}

struct ScreenShareHandler {
    typealias Callback = () -> Void

    var status: () -> ObservableValue<ScreenSharingStatus>
    var updateState: (CoreSdkClient.VisitorScreenSharingState?) -> Void
    var stop: (Callback?) -> Void
    var cleanUp: Callback
}
