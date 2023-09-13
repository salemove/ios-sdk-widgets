import Foundation

extension Localization {
    static func tr(
        _ table: String,
        _ key: String,
        _ args: CVarArg...,
        fallback value: String,
        stringProviding: StringProviding? = Glia.sharedInstance.stringProviding,
        bundleManaging: BundleManaging = .live
    ) -> String {
        guard
            let stringProviding,
            let remoteString = stringProviding.getRemoteString(key)
        else {
            let format = bundleManaging.current().localizedString(forKey: key, value: value, table: table)
            return String(format: format, locale: Locale.current, arguments: args)
        }

        return remoteString
    }
}
