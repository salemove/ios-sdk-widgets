import WebKit

#if DEBUG
extension WKNavigationPolicyProvider {
    static let mock = Self { _ in
        (.cancel, false)
    }
}
#endif
