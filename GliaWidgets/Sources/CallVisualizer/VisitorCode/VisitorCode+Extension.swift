import Foundation

#if DEBUG
extension CoreSdkClient.VisitorCode {
    init(code: String, expiresAt: Date) throws {
        let payload = """
        {
            "code": "\(code)",
            "expiresAt": "\(ISO8601DateFormatter().string(from: expiresAt))"
        }
        """
        let json = Data(payload.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        self = try decoder.decode(CoreSdkClient.VisitorCode.self, from: json)
    }
}

extension CoreSdkClient.VisitorCode {
    static func mock() throws -> CoreSdkClient.VisitorCode {
        try .init(
            code: "123456",
            expiresAt: Date().addingTimeInterval(3600)
        )
    }
}
#endif
