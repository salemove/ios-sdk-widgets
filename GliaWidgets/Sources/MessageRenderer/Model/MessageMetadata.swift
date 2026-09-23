@_spi(GliaWidgets) internal import GliaCoreSDK
import Foundation

/// Metadata supplied to a custom message renderer.
public struct MessageMetadata {
    public enum CodingKeys: String, CodingKey { case metadata }

    private enum Storage {
        case container(KeyedDecodingContainer<CodingKeys>)
        case core(CoreSdkClient.Message.Metadata)
    }

    private let storage: Storage

    /// Creates metadata from a decoding container containing the metadata field.
    public init(container: KeyedDecodingContainer<CodingKeys>) {
        storage = .container(container)
    }

    /// Decodes the metadata into the supplied model using the original decoder's strategies.
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        switch storage {
        case let .container(container):
            return try container.decode(type, forKey: .metadata)
        case let .core(metadata):
            return try metadata.decode(type)
        }
    }

    init(coreMetadata: CoreSdkClient.Message.Metadata) {
        storage = .core(coreMetadata)
    }

    init(container: KeyedDecodingContainer<CoreSdkClient.Message.Metadata.CodingKeys>) {
        self.init(coreMetadata: .init(container: container))
    }
}

struct HtmlMetadata: Decodable {
    let html: String
}

extension HtmlMetadata {
    struct Option {
        let text: String
        let value: String
    }
}
