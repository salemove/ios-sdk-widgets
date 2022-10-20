import WebKit

struct WKNavigationPolicyProvider {
    /// Receives URL that needs to be handled
    /// Returns tuple of:
    /// WKNavigationActionPolicy that will be passed to WKNavigationDelegate webView(webView:decidePolicyFor:decisionHandler:)
    /// Bool value indicating eather we need to handle selection of provided URL
    var policy: (URL) -> (policy: WKNavigationActionPolicy, shouldHandleUrlSelection: Bool)
}
