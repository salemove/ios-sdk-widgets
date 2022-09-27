import WebKit

extension WKNavigationPolicyProvider {
    static let customResponseCard = Self { url in
        switch url.scheme {
        case URLScheme.about.rawValue:
            return (.allow, false)
        case URLScheme.http.rawValue,
            URLScheme.https.rawValue,
            URLScheme.tel.rawValue,
            URLScheme.mailto.rawValue:
            return (.cancel, true)
        default:
            return (.cancel, false)
        }
    }
}
