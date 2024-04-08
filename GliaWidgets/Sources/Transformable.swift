/// Helper for chaining in-place mutations on value types. Useful in unit tests when changing dependencies
/// passed by `Environment`, for example:
/// ```
/// extension EngagementCoordinator.Environment: Transformable {}
/// extension UIKitBased.UIApplication: Transformable {}
///
/// let environment = EngagementCoordinator.Environment.mock.transform {
///   $0.uiApplication = .failing.transform { $0.windows = { [ .mock() ] } }
/// }
protocol Transformable {
    func transform(_ rewrite: (inout  Self) -> Void) -> Self
}

extension Transformable {
    func transform(_ rewrite: (inout  Self) -> Void) -> Self {
        var value = self
        rewrite(&value)
        return value
    }
}
