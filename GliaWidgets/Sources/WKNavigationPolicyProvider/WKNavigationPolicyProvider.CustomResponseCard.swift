import WebKit

extension WKNavigationPolicyProvider {
    static let customResponseCard = Self { request in
        switch request.url.scheme?.lowercased() {
        case URLScheme.about.rawValue:
            // Initial `loadHTMLString(_:baseURL: nil)` load and srcdoc frames.
            return (.allow, false)
        case URLScheme.http.rawValue,
            URLScheme.https.rawValue,
            URLScheme.tel.rawValue,
            URLScheme.mailto.rawValue:
            // Script navigation, meta refresh, form submission and iframes must never open externally.
            let isLinkTap = request.navigationType == .linkActivated && request.target != .subframe
            return (.cancel, isLinkTap)
        default:
            return (.cancel, false)
        }
    }
}
