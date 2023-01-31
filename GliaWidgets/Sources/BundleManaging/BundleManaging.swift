import Foundation

struct BundleManaging {
    var current: () -> Bundle
}

extension BundleManaging {
    static let live: Self = .init(current: {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: Glia.self)
        #endif
    })
}
