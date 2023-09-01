import Foundation

extension Localization {
    static func operatorName(
        _ name: String?,
        on templateString: String? = nil
    ) -> String {
        guard
            let templateString,
            templateString.range(of: "{operatorName}") != nil
        else {
            return name ?? Localization.Engagement.defaultOperatorName
        }

        return templateString.withOperatorName(name)
    }
}
