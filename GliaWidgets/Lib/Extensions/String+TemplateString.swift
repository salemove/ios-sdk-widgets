extension String {
    func withOperatorName(_ name: String?) -> String {
        let name = name ?? L10n.operator
        return replacingOccurrences(of: "{operatorName}", with: name)
    }

    func withCallDuration(_ duration: String) -> String {
        return replacingOccurrences(of: "{callDuration}", with: duration)
    }
}
