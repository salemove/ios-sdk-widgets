@testable import GliaWidgets

extension FileSystemStorage.Environment {
    static let failing = Self(
        fileManager: .failing,
        data: .failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        }
    )
}
