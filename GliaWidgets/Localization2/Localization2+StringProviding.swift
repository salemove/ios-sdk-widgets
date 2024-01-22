import Foundation

extension Localization2 {
    static func tr(
        _ table: String,
        _ key: String,
        _ args: CVarArg...,
        fallback value: String,
        stringProviding: () -> StringProvidingPhase?,
        bundleManaging: BundleManaging = .live
    ) -> String {
        guard
            let stringProviding = stringProviding(),
            let remoteString = stringProviding(key)
        else {
            let format = bundleManaging.current().localizedString(forKey: key, value: value, table: table)
            return String(format: format, locale: Locale.current, arguments: args)
        }

        return remoteString
    }
}
