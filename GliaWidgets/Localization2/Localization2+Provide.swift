import Foundation

extension Localization2 {
    struct Providing {
        var provide: () -> Localization2

        func callAsFunction() -> Localization2 {
            provide()
        }
    }
}

extension Localization2.Providing {
    static let mock = Self(provide: { .mock })
}
