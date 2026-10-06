import Foundation

enum URLScheme: String, CaseIterable {
    case http, https, tel, mailto, about
}

extension URLScheme {
    /// Schemes iOS always handles with a built-in app (Safari, Phone, Mail).
    static let systemDefaults: Set<URLScheme> = [.http, .https, .tel, .mailto]
}

extension URL {
    /// URLs with these schemes can be opened without asking `canOpenURL` first.
    /// `canOpenURL` returns `false` for any scheme the host app does not list in
    /// `LSApplicationQueriesSchemes`, even when a handling app is installed.
    var hasSystemDefaultScheme: Bool {
        scheme
            .flatMap { URLScheme(rawValue: $0.lowercased()) }
            .map(URLScheme.systemDefaults.contains) ?? false
    }
}
