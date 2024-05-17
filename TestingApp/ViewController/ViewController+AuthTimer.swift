import Foundation

extension ViewController {
    /// We don't have a way to report back to viewController,
    /// about deauthentication because of an error. We need to
    /// check it manually so that UI renders properly.
    func startAuthTimer() {
        authTimer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(checkAuthState),
            userInfo: nil,
            repeats: true
        )
    }

    func stopAuthTimer() {
        authTimer?.invalidate()
        authTimer = nil
    }

    @objc func checkAuthState() {
        guard let authentication, authentication.isAuthenticated else {
            authentication = nil
            stopAuthTimer()
            renderAuthenticatedState(isAuthenticated: false)
            return
        }
        renderAuthenticatedState(isAuthenticated: true)
    }
}
