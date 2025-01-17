import Foundation

extension CombineBased.CombineScheduler {
    // Till we don't have a mock tools for Combine, we will use the live scheduler
    // Once MOB-4008 is ready, we can use AnyScheduler here.
    static let mock = live
}
