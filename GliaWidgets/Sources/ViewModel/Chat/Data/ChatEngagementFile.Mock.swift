#if DEBUG
import Foundation

extension ChatEngagementFile {
    static func mock(
        id: String = "",
        url: URL? = nil,
        name: String? = nil,
        size: Double? = nil,
        contentType: String? = nil,
        isDeleted: Bool? = nil
    ) -> ChatEngagementFile {
        .init(
            id: id,
            url: url,
            name: name,
            size: size,
            contentType: contentType,
            isDeleted: isDeleted
        )
    }
}
#endif
