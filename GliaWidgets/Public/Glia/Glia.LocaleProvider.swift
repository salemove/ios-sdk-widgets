import Foundation

extension Glia {
    /// Locale provider is used for retrieving remote strings for associated key
    public final class LocaleProvider {
        let locale: (String) -> String?

        init(locale: @escaping (String) -> String?) {
            self.locale = locale
        }
    }
}

extension Glia.LocaleProvider {
    /// Retrieves remote string value if exists
    /// - Parameter key: String value which remote string is associated with.
    /// - Returns: `String` value if exists, otherwise returns `nil`
    public func getRemoteString(_ key: String) -> String? {
        locale(key)
    }
}
