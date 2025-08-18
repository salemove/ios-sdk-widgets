@testable import GliaWidgets

extension SecureConversations.Availability.Environment {
    static let failing = Self(
        getQueues: {
            fail("\(Self.self).getQueues")
            throw NSError(domain: "getQueues", code: -1)
        },
        isAuthenticated: {
            fail("\(Self.self).isAuthenticated")
            return false
        },
        log: .failing,
        queuesMonitor: .failing,
        getCurrentEngagement: {
            fail("\(Self.self).getCurrentEngagement")
            return .mock()
        }
    )
}
