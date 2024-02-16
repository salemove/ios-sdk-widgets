import Foundation

extension ProcessInfoHandling {
    static let live = Self {
        ProcessInfo.processInfo.environment
    }
}
