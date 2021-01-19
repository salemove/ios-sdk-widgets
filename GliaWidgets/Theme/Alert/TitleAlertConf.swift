public struct TitleAlertConf {
    public var title: String
}

extension TitleAlertConf {
    func withOperatorName(_ name: String) -> TitleAlertConf {
        let newTitle = title.replacingOccurrences(of: "{operatorName}", with: name)
        return TitleAlertConf(title: newTitle)
    }
}
