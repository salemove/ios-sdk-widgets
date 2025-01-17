import Foundation

extension CombineBased.CombineScheduler {
    static let live = Self(
        main: { DispatchQueue.main },
        global: { DispatchQueue.global() }
    )
}
