#if DEBUG
import Foundation

extension ConditionalCompilationClient {
    static let mock = Self(isDebug: { false })
}
#endif
