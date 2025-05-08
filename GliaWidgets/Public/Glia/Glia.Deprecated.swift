import Foundation
import GliaCoreSDK

extension Glia {
    /// Deprecated, use ``Glia.getVisitorInfo(completion:)`` instead.
    @available(*, deprecated, message: "Deprecated, use ``Glia.getVisitorInfo(completion:)`` instead. ")
    public func fetchVisitorInfo(completion: @escaping (Result<GliaCore.VisitorInfo, Error>) -> Void) {
        environment.coreSdk.getVisitorInfoDeprecated(completion)
    }

    /// Deprecated, use ``Glia.getQueues(completion:)`` instead.
    @available(*, deprecated, message: "Deprecated, use ``Glia.getQueues(completion:)`` instead. ")
    public func listQueues(_ completion: @escaping (Result<[Queue], Error>) -> Void) {
        getQueues(completion)
    }

    @available(*, deprecated, message: "Deprecated, use ``Glia.updateVisitorInfo(info:completion:)`` instead.")
    public func updateVisitorInfo(
        _ info: GliaCoreSDK.VisitorInfoUpdate,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard configuration != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        environment.coreSdk.updateVisitorInfoDeprecated(info, completion)
    }
}
