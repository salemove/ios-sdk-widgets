#if DEBUG
import Foundation

extension ProcessInfoHandling {
    static func mock(info: @escaping () -> [String: String] = { [:] }) -> Self {
        .init(info: info)
    }
}
#endif
