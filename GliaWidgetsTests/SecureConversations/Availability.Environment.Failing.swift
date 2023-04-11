@testable import GliaWidgets

extension SecureConversations.Availability.Environment {
    static let failing = Self(
        listQueues: { _ in
            fail("\(Self.self).listQueues")
        },
        queueIds: [],
        isAuthenticated: {
            fail("\(Self.self).isAuthenticated")
            return false
        }
    )
}
