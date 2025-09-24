import Foundation

typealias MessageMetadata = CoreSdkClient.Message.Metadata

struct HtmlMetadata: Decodable {
    let html: String
}

extension HtmlMetadata {
    struct Option {
        let text: String
        let value: String
    }
}
