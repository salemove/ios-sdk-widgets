import Foundation

/// Provides interfaces for managing Live Observation feature.
public struct LiveObservation {
    let environment: Environment

    /// Pauses live observation.
    ///
    /// This method is used to hide sensitive data from the screen by pausing live observation.
    public func pause() {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "pause"
        )
        environment.coreSdk.liveObservation.pause()
    }

    /// Resumes live observation.
    ///
    /// This method resumes live observation session after it has been paused.
    public func resume() {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "resume"
        )
        environment.coreSdk.liveObservation.resume()
    }
}
