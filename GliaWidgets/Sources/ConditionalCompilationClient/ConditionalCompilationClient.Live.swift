import Foundation

extension ConditionalCompilationClient {
    static let live = Self(
        isDebug: {
            #if DEBUG
                true
            #else
                false
            #endif
        }
    )
}
