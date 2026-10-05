import WebKit

struct WKNavigationPolicyProvider {
    struct Request: Equatable {
        enum Target: Equatable {
            case mainFrame
            case subframe
            /// `target="_blank"` link, where WebKit reports no target frame.
            case newWindow
        }

        let url: URL
        let navigationType: WKNavigationType
        let target: Target
    }

    /// Receives the navigation that needs a decision.
    /// Returns tuple of:
    /// WKNavigationActionPolicy that will be passed to WKNavigationDelegate webView(webView:decidePolicyFor:decisionHandler:)
    /// Bool value indicating whether the URL should be handed to the integrator-facing link handling
    var policy: (Request) -> (policy: WKNavigationActionPolicy, shouldHandleUrlSelection: Bool)
}

extension WKNavigationPolicyProvider.Request {
    init?(_ action: WKNavigationAction) {
        guard let url = action.request.url else { return nil }
        self.url = url
        self.navigationType = action.navigationType
        self.target = action.targetFrame.map { $0.isMainFrame ? .mainFrame : .subframe } ?? .newWindow
    }
}
