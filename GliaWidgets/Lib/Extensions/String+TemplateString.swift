extension String {
    func withOperatorName(_ name: String?) -> String {
        let name = name ?? L10n.operator
        return replacingOccurrences(of: "{operatorName}", with: name)
    }
}
