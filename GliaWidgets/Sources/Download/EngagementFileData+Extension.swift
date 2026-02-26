import Foundation

#if DEBUG
extension CoreSdkClient.EngagementFileData {
    convenience init(data: Data) {
        self.init(data: data)
    }

    static func mock() -> CoreSdkClient.EngagementFileData {
        let payload = "mock file content"
        let json = Data(payload.utf8)
        return .init(data: json)
    }
}
#endif
