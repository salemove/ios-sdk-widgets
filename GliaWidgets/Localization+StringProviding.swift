import Foundation

extension Localization {
    static func tr(
        _ table: String,
        _ key: String,
        _ args: CVarArg...,
        fallback value: String,
        // Usage of shared instance there is acceptable, because it's global method.
        // But it should not be followed with other features in future,
        // because it causes problems in tests.
        stringProviding: StringProvidingPhase? = Glia.sharedInstance.stringProvidingPhase,
        bundleManaging: BundleManaging = .live
    ) -> String {
        guard
            let stringProviding,
            let remoteString = stringProviding(key)
        else {
            let format = bundleManaging.current().localizedString(forKey: key, value: value, table: table)
            return String(format: format, locale: Locale.current, arguments: args)
        }

        return remoteString
    }
}
