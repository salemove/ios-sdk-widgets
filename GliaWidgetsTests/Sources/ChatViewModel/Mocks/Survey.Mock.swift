import Foundation
@testable import GliaWidgets

extension CoreSdkClient.Survey {
    static func mock(
        id: String = "mock",
        description: String = "mock",
        name: String = "mock",
        title: String = "mock",
        type: String = "visitor",
        siteId: String = "mock"
    ) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: [
            "id": id,
            "description": description,
            "name": name,
            "title": title,
            "type": type,
            "siteId": siteId,
            "questions": []
        ])
        return try JSONDecoder().decode(CoreSdkClient.Survey.self, from: data)
    }
}
