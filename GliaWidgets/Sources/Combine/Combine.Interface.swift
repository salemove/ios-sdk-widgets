import Foundation
import Combine

enum CombineBased {
    struct CombineScheduler {
        var main: () -> Scheduler
        var global: () -> Scheduler
    }

    typealias Scheduler = DispatchQueue
}
