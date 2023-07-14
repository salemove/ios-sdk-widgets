import Foundation
@testable import GliaWidgets

extension GvaOption {
    static func mock(
        text: String = "",
        value: String? = nil,
        url: String? = nil,
        urlTarget: String? = nil,
        destinationPdBroadcastEvent: String? = nil
    ) -> GvaOption {
        return .init(
            text: text,
            value: value,
            url: url,
            urlTarget: urlTarget,
            destinationPdBroadcastEvent: destinationPdBroadcastEvent
        )
    }
}
