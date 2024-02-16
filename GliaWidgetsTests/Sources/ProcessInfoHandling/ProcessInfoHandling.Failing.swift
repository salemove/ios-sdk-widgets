import Foundation
@testable import GliaWidgets

extension ProcessInfoHandling {
    static let failing = Self {
        fail("\(Self.self).info")
        return [:]
    }
}
