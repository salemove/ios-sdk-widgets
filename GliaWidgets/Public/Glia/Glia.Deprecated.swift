import GliaCoreSDK

extension Glia {
    /// Deprecated, use ``Glia.getVisitorInfo(completion:`` instead.
    @available(*, deprecated, message: "Deprecated, use ``Glia.getVisitorInfo(completion:`` instead. ")
    public func fetchVisitorInfo(completion: @escaping (Result<GliaCore.VisitorInfo, Error>) -> Void) {
        getVisitorInfo(completion: completion)
    }
}
