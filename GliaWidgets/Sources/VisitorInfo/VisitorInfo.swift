import Foundation

public struct VisitorInfo: Equatable, Decodable {
    /// Visitor's name
    public let name: String?

    /// Visitor's email address
    public let email: String?

    /// Visitor's phone number
    public let phone: String?

    /// Visitor related note
    public let note: String?

    /// Visitor's custom attributes
    public let customAttributes: [String: String]?

    /// Is visitor banned
    public let banned: Bool

    /// Visitor's generated name
    public let generatedName: String?

    /// Visitor's href
    public let href: String?

    /// Visitor's id
    public let id: String?

    /// Visitor's external id
    public let externalId: String?
}

extension CoreSdkClient.CoreVisitorInfo {
    func asWidgetSdkVisitorInfo() -> VisitorInfo {
        .init(
            name: name,
            email: email,
            phone: phone,
            note: note,
            customAttributes: customAttributes,
            banned: banned,
            generatedName: generatedName,
            href: href,
            id: id,
            externalId: externalId
        )
    }
}

#if DEBUG
extension VisitorInfo {
    static let mock = VisitorInfo(
        name: "Test",
        email: "test@example.com",
        phone: "+123456789",
        note: "test note",
        customAttributes: ["foo": "bar"],
        banned: false,
        generatedName: nil,
        href: nil,
        id: "id",
        externalId: "externalId"
    )
}
#endif
