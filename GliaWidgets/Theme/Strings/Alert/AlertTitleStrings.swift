public struct AlertTitleStrings {
    public var title: String
}

extension AlertTitleStrings {
    func withOperatorName(_ name: String) -> AlertTitleStrings {
        let newTitle = title.replacingOccurrences(of: "{operatorName}", with: name)
        return AlertTitleStrings(title: newTitle)
    }
}
