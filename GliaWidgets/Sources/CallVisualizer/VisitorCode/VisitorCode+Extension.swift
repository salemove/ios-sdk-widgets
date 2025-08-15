import GliaCoreSDK

extension VisitorCode {
    public init(code: String, expiresAt: Date) {
        let json = """
            {
                "code": "\(code)",
                "expiresAt": "\(ISO8601DateFormatter().string(from: expiresAt))"
            }
            """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self = try! decoder.decode(VisitorCode.self, from: json)
    }

    static let mock = VisitorCode(code: "123456", expiresAt: Date().addingTimeInterval(3600))
}
