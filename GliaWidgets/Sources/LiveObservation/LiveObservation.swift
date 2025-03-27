import Foundation

/// Provides interfaces for managing Live Observation feature.
public struct LiveObservation {
    let environment: Environment

    /// Pauses live observation.
    ///
    /// This method is used to hide sensitive data from the screen by pausing live observation.
    public func pause() {
        environment.coreSdk.liveObservation.pause()
    }

    /// Resumes live observation.
    ///
    /// This method resumes live observation session after it has been paused.
    public func resume() {
        environment.coreSdk.liveObservation.resume()
    }
}

extension LiveObservation {
    struct Environment {
        let coreSdk: CoreSdkClient
    }
}

extension LiveObservation.Environment {
    static func create(with environment: Glia.Environment) -> Self {
        .init(coreSdk: environment.coreSdk)
    }
}
