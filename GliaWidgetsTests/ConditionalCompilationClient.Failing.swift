@testable import GliaWidgets

extension ConditionalCompilationClient {
    static let failing = Self(
        isDebug: {
            fail("\(Self.self).isDebug")
            return false
        }
    )
}
