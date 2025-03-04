import Foundation

extension AnyCombineScheduler {
    static let mock = AnyCombineScheduler(
        main: AnyScheduler(ImmediateScheduler()),
        global: AnyScheduler(ImmediateScheduler())
    )
}
