import Foundation

extension CoreSdkClient {
    struct EngagementFileData {
        let data: Data
    }
}

#if DEBUG
extension CoreSdkClient.EngagementFileData {
    static func mock() -> Self {
        .init(data: Data("mock file content".utf8))
    }
}
#endif
