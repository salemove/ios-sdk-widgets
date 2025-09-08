import GliaCoreSDK

#if DEBUG
extension EngagementFileData {
    public convenience init(data: Data) {
        self.init(data: data)
    }

    public static func mock() -> EngagementFileData {
        let sampleData = "mock file content".data(using: .utf8)!
        return EngagementFileData(data: sampleData)
    }
}
#endif
