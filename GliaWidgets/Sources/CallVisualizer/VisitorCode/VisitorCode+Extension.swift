import GliaCoreSDK

#if DEBUG
extension VisitorCode {
    public init(code: String, expiresAt: Date) throws {
        let payload = """
        {
            "code": "\(code)",
            "expiresAt": "\(ISO8601DateFormatter().string(from: expiresAt))"
        }
        """
        let json = Data(payload.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        self = try decoder.decode(VisitorCode.self, from: json)
    }
}

extension VisitorCode {
    static func mock() throws -> VisitorCode {
        try VisitorCode(
            code: "123456",
            expiresAt: Date().addingTimeInterval(3600)
        )
    }
}
#endif
