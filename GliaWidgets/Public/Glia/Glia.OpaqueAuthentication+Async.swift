import Foundation

public extension Glia.Authentication {
    /// Authenticate visitor.
    ///
    /// Async equivalent of `authenticate(with:accessToken:completion:)`.
    func authenticate(
        with idToken: IdToken,
        accessToken: AccessToken?
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            authenticate(with: idToken, accessToken: accessToken) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Deauthenticate visitor.
    ///
    /// Async equivalent of `deauthenticate(shouldStopPushNotifications:completion:)`.
    func deauthenticate(
        shouldStopPushNotifications: Bool = false
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            deauthenticate(shouldStopPushNotifications: shouldStopPushNotifications) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Refresh access token.
    ///
    /// Async equivalent of `refresh(with:accessToken:completion:)`.
    func refresh(
        with idToken: IdToken,
        accessToken: AccessToken?
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            refresh(with: idToken, accessToken: accessToken) { result in
                continuation.resume(with: result)
            }
        }
    }
}
