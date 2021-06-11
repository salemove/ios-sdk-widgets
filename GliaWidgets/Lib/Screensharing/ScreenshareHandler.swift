import SalemoveSDK

class ScreenshareHandler {
    private var visitorState: VisitorScreenSharingState?

    func updateState(to state: VisitorScreenSharingState?) {
        visitorState = state
    }

    func stop(completion: (() -> Void)? = nil) {
        visitorState?.localScreen?.stopSharing()
        visitorState = nil
        completion?()
    }

    func cleanUp() {
        visitorState = nil
    }
}
