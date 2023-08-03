import Foundation
import GliaCoreSDK

/// Defines wrapper structure for getting decoding container.
/// This container can be used when message metadata is needed in
/// tests.
struct CoreSdkMessageMetadataContainer: Decodable {
    let container: KeyedDecodingContainer<GliaCoreSDK.Message.Metadata.CodingKeys>

    init(from decoder: Decoder) throws {
        self.container = try decoder.container(
            keyedBy: GliaCoreSDK.Message.Metadata.CodingKeys.self
        )
    }

    /// Creates instance with decoding container inside.
    /// This initializer can be used for created mocked Metadata with passing
    /// json-data inside of this initializer.
    /// NB! Empty 'jsonData' will lead to decoding error.
    init(
        jsonData: Data,
        jsonDecoder: JSONDecoder = .init()
    ) throws {
        self = try jsonDecoder.decode(CoreSdkMessageMetadataContainer.self, from: jsonData)
    }
}
