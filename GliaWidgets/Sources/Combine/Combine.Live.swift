import Foundation

extension AnyCombineScheduler {
    static let live = AnyCombineScheduler(
        main: AnyScheduler(DispatchQueue.main),
        global: AnyScheduler(DispatchQueue.global(qos: .default))
    )
}
