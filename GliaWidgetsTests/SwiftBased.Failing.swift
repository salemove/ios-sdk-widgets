@testable import GliaWidgets

extension SwiftBased.Print {
    static let failing = Self(printClosure: { _, _, _ in fail("\(Self.self).printClosure") })
}
