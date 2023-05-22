import GliaCoreSDK

public typealias MessageMetadata = GliaCoreSDK.Message.Metadata

struct HtmlMetadata: Decodable {
    let html: String
}

extension HtmlMetadata {
    struct Option {
        let text: String
        let value: String
    }
}
