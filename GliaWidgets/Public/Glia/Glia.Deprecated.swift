import Foundation
import GliaCoreSDK

extension Glia {
    /// Clear visitor session
    ///
    /// - Parameters:
    ///   - completion: Completion handler.
    ///
    /// - Important: Note, that in case of ongoing engagement, `clearVisitorSession` must be called
    ///   after ending engagement, because `GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed`
    ///   will occur otherwise.
    ///
    @available(*, deprecated, message: "Deprecated, use ``Glia.clearVisitorData()`` instead.")
    public func clearVisitorSession(_ completion: @escaping (Result<Void, Error>) -> Void) {
        environment.openTelemetry.logger.logDeprecatedApiUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "clearVisitorSession(_:)"
        )
        loggerPhase.logger.prefixed(Self.self).info("Clear visitor session")
        guard environment.coreSdk.getNonTransferredSecureConversationEngagement() == nil else {
            completion(.failure(GliaError.clearingVisitorSessionDuringEngagementIsNotAllowed))
            return
        }
        environment.coreSdk.legacyClearSession()
        completion(.success(()))
    }

    /// Deprecated, use ``Glia.getVisitorInfo(completion:)`` instead.
    @available(*, deprecated, message: "Deprecated, use ``Glia.getVisitorInfo(completion:)`` instead. ")
    public func fetchVisitorInfo(completion: @escaping (Result<GliaCore.VisitorInfo, Error>) -> Void) {
        environment.openTelemetry.logger.logDeprecatedApiUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "fetchVisitorInfo(completion:)"
        )
        environment.coreSdk.getVisitorInfoDeprecated(completion)
    }

    /// Deprecated, use ``Glia.getQueues(completion:)`` instead.
    @available(*, deprecated, message: "Deprecated, use ``Glia.getQueues(completion:)`` instead. ")
    public func listQueues(_ completion: @escaping (Result<[Queue], Error>) -> Void) {
        environment.openTelemetry.logger.logDeprecatedApiUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "listQueues(_:)"
        )
        getQueues(completion)
    }

    @available(*, deprecated, message: "Deprecated, use ``Glia.updateVisitorInfo(info:completion:)`` instead.")
    public func updateVisitorInfo(
        _ info: GliaCoreSDK.VisitorInfoUpdate,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        environment.openTelemetry.logger.logDeprecatedApiUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "updateVisitorInfo(_:completion:)"
        )
        guard configuration != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        environment.coreSdk.updateVisitorInfoDeprecated(info, completion)
    }
}
